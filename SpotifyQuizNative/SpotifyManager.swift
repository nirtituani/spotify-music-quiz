import Foundation
import UIKit
import SpotifyiOS
import Combine
import AVFoundation

class SpotifyManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var currentTrackName: String?
    @Published var isPlaying = false
    @Published var isReconnecting = false // Track if we're attempting to reconnect
    
    // MARK: - Private Properties
    private let clientID = SpotifyConfig.clientID
    private let redirectURI = URL(string: SpotifyConfig.redirectURI)!
    private var connectionToken: String?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10 // Increased from 5 to 10
    private var reconnectTimeoutTimer: Timer?
    private var isConnecting = false // Track if connection is in progress
    private var connectionKeepAliveTimer: Timer?
    
    // Token storage keys
    private let tokenKey = "SpotifyAccessToken"
    private let tokenExpirationKey = "SpotifyTokenExpiration"
    
    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        config.playURI = ""
        config.tokenSwapURL = URL(string: "")
        config.tokenRefreshURL = URL(string: "")
        // Keep connection alive as long as possible
        return config
    }()
    
    private lazy var appRemote: SPTAppRemote = {
        let remote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        remote.delegate = self
        return remote
    }()
    
    // MARK: - Singleton
    static let shared = SpotifyManager()
    
    private override init() {
        super.init()
        // DON'T auto-restore token on init - wait for user action or app becoming active
        print("SpotifyManager initialized")
        
        // Configure audio session to keep connection alive
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Set category to playback with options to allow background and mix with others
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            print("✓ Audio session configured for background playback")
        } catch {
            print("⚠️ Failed to configure audio session: \(error)")
        }
    }
    
    private func startConnectionKeepAlive() {
        // Stop any existing timer
        connectionKeepAliveTimer?.invalidate()
        
        // WORKAROUND for Spotify App Remote SDK limitation:
        // The SDK disconnects after 30 seconds of no playback
        // Solution: Resume playback briefly every 25 seconds
        // Source: https://community.spotify.com/t5/Spotify-for-Developers/iOS-amp-Android-Remote-SDK-loses-connection-after-paused-for-30s/td-p/7077461
        
        connectionKeepAliveTimer = Timer.scheduledTimer(withTimeInterval: 25.0, repeats: true) { [weak self] _ in
            guard let self = self, self.appRemote.isConnected else { return }
            
            // Check if music is currently paused
            self.appRemote.playerAPI?.getPlayerState { result, error in
                if let playerState = result as? SPTAppRemotePlayerState {
                    if playerState.isPaused {
                        print("🔄 Keep-alive: Music paused, doing brief resume/pause to prevent disconnect")
                        
                        // Resume for a tiny moment
                        self.appRemote.playerAPI?.resume({ _, _ in
                            // Immediately pause again after 100ms
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.appRemote.playerAPI?.pause({ _, _ in
                                    print("✓ Keep-alive: Brief resume/pause cycle complete")
                                })
                            }
                        })
                    } else {
                        print("🔄 Keep-alive: Music playing, no action needed")
                    }
                }
            }
        }
        
        print("✓ Connection keep-alive timer started (25s interval - prevents 30s disconnect)")
    }
    
    private func stopConnectionKeepAlive() {
        connectionKeepAliveTimer?.invalidate()
        connectionKeepAliveTimer = nil
        print("🛑 Connection keep-alive timer stopped")
    }
    
    // MARK: - Public Methods
    
    /// Connect to Spotify
    func connect() {
        guard !appRemote.isConnected && !isConnecting else {
            print("⚠️ Already connected or connecting - skipping connect()")
            return
        }
        
        isConnecting = true
        print("🔄 Initiating connection...")
        appRemote.connect()
    }
    
    /// Handle app becoming active - reconnect if needed
    func handleAppBecameActive() {
        print("🔄 App became active - checking connection...")
        
        // Don't try to connect if already connecting or connected
        if isConnecting {
            print("⚠️ Connection already in progress - skipping")
            return
        }
        
        if appRemote.isConnected {
            print("✅ Already connected - no action needed")
            return
        }
        
        // Try to restore saved token if we don't have one in memory
        if connectionToken == nil {
            if let savedToken = UserDefaults.standard.string(forKey: tokenKey),
               let expirationDate = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date,
               Date() < expirationDate {
                print("✓ Restoring saved token from UserDefaults")
                connectionToken = savedToken
                appRemote.connectionParameters.accessToken = savedToken
            }
        }
        
        // If we have a token but not connected, try to reconnect
        if let token = connectionToken {
            print("🔄 Have token but not connected - reconnecting...")
            appRemote.connectionParameters.accessToken = token
            isConnecting = true
            appRemote.connect()
        } else {
            print("❌ No token available - waiting for user login")
        }
    }
    
    /// Set the connection token from OAuth callback
    func setConnectionToken(_ token: String) {
        self.connectionToken = token
        appRemote.connectionParameters.accessToken = token
        print("Connection token set: \(token.prefix(10))...")
        
        // Save token persistently
        saveToken(token)
        
        // Connect only if not already connecting
        if !appRemote.isConnected && !isConnecting {
            isConnecting = true
            print("🔄 Connecting with new token...")
            appRemote.connect()
        } else {
            print("⚠️ Already connected or connecting - not starting new connection")
        }
    }
    
    /// Disconnect from Spotify
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    /// Authorize with Spotify (OAuth)
    func authorize() {
        // Use SDK authorization but we'll pause immediately after connection
        let requestedScopes = ["app-remote-control", "user-read-private", "playlist-read-private"]
        
        // Set a flag to prevent auto-play
        appRemote.connectionParameters.accessToken = nil
        
        appRemote.authorizeAndPlayURI("", asRadio: false, additionalScopes: requestedScopes) { [weak self] success in
            if success {
                print("Authorization successful")
                // Don't connect here - wait for token to be set via callback
            } else {
                print("Authorization failed")
            }
        }
    }
    
    /// Play a track by Spotify URI
    func playTrack(uri: String) {
        guard appRemote.isConnected else {
            print("App Remote not connected")
            return
        }
        
        appRemote.playerAPI?.play(uri, callback: { [weak self] result, error in
            if let error = error {
                print("Error playing track: \(error.localizedDescription)")
            } else {
                print("Successfully started playing: \(uri)")
                self?.isPlaying = true
            }
        })
    }
    
    /// Pause playback
    func pause() {
        guard appRemote.isConnected else { return }
        
        appRemote.playerAPI?.pause({ result, error in
            if let error = error {
                print("Error pausing: \(error.localizedDescription)")
            } else {
                print("Paused successfully")
            }
        })
        isPlaying = false
    }
    
    /// Resume playback
    func resume() {
        guard appRemote.isConnected else { return }
        
        appRemote.playerAPI?.resume({ result, error in
            if let error = error {
                print("Error resuming: \(error.localizedDescription)")
            } else {
                print("Resumed successfully")
            }
        })
        isPlaying = true
    }
    
    /// Get current playback state
    func getPlaybackState() {
        guard appRemote.isConnected else { return }
        
        appRemote.playerAPI?.getPlayerState { [weak self] result, error in
            if let error = error {
                print("Error getting player state: \(error.localizedDescription)")
            } else if let playerState = result as? SPTAppRemotePlayerState {
                self?.currentTrackName = playerState.track.name
                self?.isPlaying = !playerState.isPaused
                print("Current track: \(playerState.track.name)")
            }
        }
    }
}

// MARK: - SPTAppRemoteDelegate
extension SpotifyManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("✅ App Remote connected successfully")
        isConnected = true
        isConnecting = false // Clear connecting flag
        isReconnecting = false // Clear reconnecting flag
        reconnectAttempts = 0 // Reset counter on successful connection
        
        // Cancel timeout timer
        reconnectTimeoutTimer?.invalidate()
        reconnectTimeoutTimer = nil
        
        // Keep screen awake to prevent iOS from suspending Spotify app
        UIApplication.shared.isIdleTimerDisabled = true
        print("✓ Screen sleep disabled to keep Spotify active")
        
        // Subscribe to player state updates
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("✓ Subscribed to player state updates")
            }
        })
        
        // Start connection keep-alive timer
        // This periodically refreshes the subscription to maintain active connection
        startConnectionKeepAlive()
        
        print("✓ Connection established - keep-alive active")
    }
    

    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("⚠️ App Remote connection failed: \(error?.localizedDescription ?? "unknown error")")
        isConnected = false
        isConnecting = false // Clear connecting flag on failure
        
        // If we were trying to reconnect and it failed, stop trying
        if isReconnecting {
            let nsError = error as NSError?
            // Check if it's "Connection refused" (Spotify app not running)
            if nsError?.code == -2000 {
                print("⚠️ Spotify app not running - stopping reconnection attempts")
                isReconnecting = false
                reconnectAttempts = 0
            } else if reconnectAttempts >= maxReconnectAttempts {
                print("⚠️ Max reconnect attempts reached")
                isReconnecting = false
                reconnectAttempts = 0
            }
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("⚠️ ========================================")
        print("⚠️ App Remote disconnected!")
        print("⚠️ Error: \(error?.localizedDescription ?? "no error")")
        print("⚠️ Error details: \(String(describing: error))")
        print("⚠️ ========================================")
        isConnected = false
        isConnecting = false // Clear connecting flag
        
        // Stop keep-alive timer
        stopConnectionKeepAlive()
        
        // Re-enable screen sleep
        UIApplication.shared.isIdleTimerDisabled = false
        
        // Check if this is the "End of stream" error (Spotify app suspended)
        let nsError = error as NSError?
        if nsError?.domain == "com.spotify.app-remote" && nsError?.code == -1002 {
            print("🔄 Spotify app was suspended - will try quick reconnect")
            
            // This is expected when Spotify app goes to background
            // Try to reconnect automatically with saved token (3 attempts max)
            if let token = connectionToken {
                isReconnecting = true
                
                // Set a shorter timeout - 5 seconds for 3 quick attempts
                reconnectTimeoutTimer?.invalidate()
                reconnectTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    if self.isReconnecting && !self.isConnected {
                        print("❌ Quick reconnect failed - Spotify app needs to be opened")
                        print("💡 Tip: Keep Spotify app running in background for best experience")
                        self.isReconnecting = false
                        self.reconnectAttempts = 0
                    }
                }
                
                // Attempt quick reconnect
                attemptReconnect()
            } else {
                print("❌ No token available - user must login again")
                isReconnecting = false
            }
        } else {
            // Some other error - don't auto-reconnect
            print("❌ Unexpected disconnect - user must login again")
            isReconnecting = false
        }
    }
    
    private func attemptReconnect() {
        guard let token = connectionToken else {
            print("Cannot reconnect: No token available")
            isReconnecting = false
            return
        }
        
        guard reconnectAttempts < 3 else {
            print("⚠️ Max reconnect attempts (3) reached. Spotify app needs to be opened manually.")
            isReconnecting = false
            reconnectAttempts = 0
            return
        }
        
        reconnectAttempts += 1
        print("🔄 Reconnect attempt \(reconnectAttempts)/3...")
        
        // Try simple reconnect first (in case Spotify is still in memory)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if !self.appRemote.isConnected && !self.isConnecting {
                self.appRemote.connectionParameters.accessToken = token
                self.isConnecting = true
                self.appRemote.connect()
            }
        }
    }
    
    // MARK: - Token Persistence
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        // Save expiration time (Spotify tokens typically expire in 1 hour, we'll use 50 minutes to be safe)
        let expirationDate = Date().addingTimeInterval(50 * 60) // 50 minutes
        UserDefaults.standard.set(expirationDate, forKey: tokenExpirationKey)
        print("✓ Token saved to UserDefaults (expires in 50 minutes)")
    }
    
    private func restoreToken() {
        guard let savedToken = UserDefaults.standard.string(forKey: tokenKey),
              let expirationDate = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date else {
            print("No saved token found")
            return
        }
        
        // Check if token is still valid
        if Date() < expirationDate {
            print("✓ Restored valid token from UserDefaults")
            connectionToken = savedToken
            appRemote.connectionParameters.accessToken = savedToken
            
            // Auto-connect with saved token
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.connect()
            }
        } else {
            print("⚠️ Saved token expired, clearing...")
            clearToken()
        }
    }
    
    private func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpirationKey)
        UserDefaults.standard.removeObject(forKey: "hasEverConnected") // Clear connection flag too
        connectionToken = nil
        print("✓ Token and connection status cleared")
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension SpotifyManager: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        currentTrackName = playerState.track.name
        isPlaying = !playerState.isPaused
        print("Player state changed - Track: \(playerState.track.name), Playing: \(!playerState.isPaused)")
    }
}
