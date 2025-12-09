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
        // NO KEEP-ALIVE NEEDED!
        // We accept the 30s disconnect and reconnect on-demand when playing next track
        // This is the smart approach - no annoying background activity
        print("✓ Connection established - will reconnect on-demand if needed")
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
    
    /// Check if we have a valid token
    func hasValidToken() -> Bool {
        guard let savedToken = UserDefaults.standard.string(forKey: tokenKey),
              let expirationDate = UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date else {
            return false
        }
        
        // Check if token is still valid
        return Date() < expirationDate
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
        
        // DON'T auto-reconnect on app becoming active
        // Let the on-demand reconnection in playTrack() handle it when needed
        // This prevents failed connection attempts when Spotify app isn't running
        print("💡 Not connected - will reconnect when playing next track")
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
    func playTrack(uri: String, completion: ((Bool) -> Void)? = nil) {
        // If not connected, reconnect first
        if !appRemote.isConnected {
            print("🔄 Not connected - reconnecting before playing track...")
            
            guard let token = connectionToken else {
                print("❌ No token available - cannot play track")
                completion?(false)
                return
            }
            
            // Reconnect and then play
            appRemote.connectionParameters.accessToken = token
            isConnecting = true
            
            // Wait for connection to establish
            var connectionObserver: NSObjectProtocol?
            connectionObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("SpotifyConnected"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                // Remove observer
                if let observer = connectionObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
                
                // Now play the track
                self?.playTrackAfterConnection(uri: uri, completion: completion)
            }
            
            // Try to connect
            appRemote.connect()
            
            // Set timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if let observer = connectionObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
                
                if self?.appRemote.isConnected == false {
                    print("⚠️ Reconnection timeout")
                    completion?(false)
                }
            }
            
            return
        }
        
        // Already connected, play directly
        playTrackAfterConnection(uri: uri, completion: completion)
    }
    
    private func playTrackAfterConnection(uri: String, completion: ((Bool) -> Void)?) {
        appRemote.playerAPI?.play(uri, callback: { [weak self] result, error in
            if let error = error {
                print("Error playing track: \(error.localizedDescription)")
                completion?(false)
            } else {
                print("✅ Successfully started playing: \(uri)")
                self?.isPlaying = true
                completion?(true)
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
        
        // Notify that connection is ready (for playTrack waiting)
        NotificationCenter.default.post(name: NSNotification.Name("SpotifyConnected"), object: nil)
        
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
        
        // DON'T auto-reconnect! Just let it disconnect.
        // We'll reconnect on-demand when user tries to play next track
        print("💡 Disconnected - will reconnect automatically when playing next track")
        isReconnecting = false
        reconnectAttempts = 0
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
