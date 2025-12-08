import Foundation
import UIKit
import SpotifyiOS
import Combine

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
    private var keepAliveTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10 // Increased from 5 to 10
    private var reconnectTimeoutTimer: Timer?
    
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
        // Try to restore saved token on init
        restoreToken()
    }
    
    // MARK: - Public Methods
    
    /// Connect to Spotify
    func connect() {
        if !appRemote.isConnected {
            appRemote.connect()
        }
    }
    
    /// Set the connection token from OAuth callback
    func setConnectionToken(_ token: String) {
        self.connectionToken = token
        appRemote.connectionParameters.accessToken = token
        print("Connection token set: \(token.prefix(10))...")
        
        // Save token persistently
        saveToken(token)
        
        // Connect (let Spotify SDK handle the connection naturally)
        if !appRemote.isConnected {
            appRemote.connect()
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
        isReconnecting = false // Clear reconnecting flag
        reconnectAttempts = 0 // Reset counter on successful connection
        
        // Cancel timeout timer
        reconnectTimeoutTimer?.invalidate()
        reconnectTimeoutTimer = nil
        
        // Subscribe to player state updates (but don't pause - let user control playback)
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("✓ Subscribed to player state updates")
            }
        })
        
        // Start lightweight keep-alive monitor
        startKeepAliveTimer()
        
        print("✓ Connection established and stable")
    }
    
    private func startKeepAliveTimer() {
        // Stop existing timer if any
        keepAliveTimer?.invalidate()
        
        // SIMPLIFIED: Just check connection health every 30 seconds (don't ping aggressively)
        // The Spotify SDK maintains its own connection - we shouldn't interfere too much
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Only check if connection is still alive, don't send unnecessary requests
            if !self.appRemote.isConnected {
                print("⚠️ Connection lost, attempting reconnect...")
                if self.connectionToken != nil {
                    self.isReconnecting = true
                }
                self.attemptReconnect()
            } else {
                print("✓ Connection still healthy")
            }
        }
        
        print("✓ Keep-alive monitor started (30 second check interval)")
    }
    
    private func stopKeepAliveTimer() {
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("App Remote connection failed: \(error?.localizedDescription ?? "unknown error")")
        isConnected = false
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("App Remote disconnected: \(error?.localizedDescription ?? "no error")")
        isConnected = false
        stopKeepAliveTimer()
        
        // Set reconnecting flag if we have a token (so we don't show login screen)
        if connectionToken != nil {
            isReconnecting = true
            print("🔄 Starting reconnection process...")
            
            // Set a timeout - if we can't reconnect in 15 seconds, give up and show login
            reconnectTimeoutTimer?.invalidate()
            reconnectTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                if self.isReconnecting && !self.isConnected {
                    print("⚠️ Reconnection timeout - giving up after 15 seconds")
                    self.isReconnecting = false
                }
            }
        }
        
        // Auto-reconnect immediately
        attemptReconnect()
    }
    
    private func attemptReconnect() {
        guard let token = connectionToken else {
            print("Cannot reconnect: No token available")
            isReconnecting = false
            return
        }
        
        guard reconnectAttempts < maxReconnectAttempts else {
            print("⚠️ Max reconnect attempts reached. Giving up.")
            isReconnecting = false
            return
        }
        
        reconnectAttempts += 1
        print("🔄 Reconnect attempt \(reconnectAttempts)/\(maxReconnectAttempts)...")
        
        // Wait briefly before reconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if !self.appRemote.isConnected {
                self.appRemote.connectionParameters.accessToken = token
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
