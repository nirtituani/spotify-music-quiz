import Foundation
import UIKit
import SpotifyiOS
import Combine

class SpotifyManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var currentTrackName: String?
    @Published var isPlaying = false
    
    // MARK: - Private Properties
    private let clientID = SpotifyConfig.clientID
    private let redirectURI = URL(string: SpotifyConfig.redirectURI)!
    private var connectionToken: String?
    private var keepAliveTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    
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
        
        // Connect and immediately pause to prevent auto-play
        if !appRemote.isConnected {
            appRemote.connect()
            
            // Pause after a very short delay (as soon as connected)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.appRemote.playerAPI?.pause({ result, error in
                    if error == nil {
                        print("Paused auto-play on connection")
                    }
                })
            }
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
        print("App Remote connected")
        isConnected = true
        reconnectAttempts = 0 // Reset counter on successful connection
        
        // IMMEDIATELY pause any playback - do this first before anything else
        appRemote.playerAPI?.pause({ result, error in
            if let error = error {
                print("Note: Could not pause playback: \(error.localizedDescription)")
            } else {
                print("✓ Paused playback on connection")
            }
        })
        
        // Also try to get player state and pause if playing
        appRemote.playerAPI?.getPlayerState { [weak self] result, error in
            if let playerState = result as? SPTAppRemotePlayerState, !playerState.isPaused {
                appRemote.playerAPI?.pause(nil)
                print("✓ Force paused active playback")
            }
        }
        
        // Subscribe to player state
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            }
        })
        
        // Start keep-alive timer to prevent disconnection
        startKeepAliveTimer()
        
        // Update UI state
        isPlaying = false
    }
    
    private func startKeepAliveTimer() {
        // Stop existing timer if any
        keepAliveTimer?.invalidate()
        
        // Aggressive keep-alive: Ping every 5 seconds to prevent any timeout
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Check if we're still connected
            if !self.appRemote.isConnected {
                print("⚠️ Keep-alive: Connection lost, attempting reconnect...")
                self.attemptReconnect()
                return
            }
            
            // Ping player state to maintain connection (prevents SDK timeout)
            self.appRemote.playerAPI?.getPlayerState { result, error in
                if error == nil {
                    print("✓ Keep-alive: Connection healthy (5s ping)")
                    self.reconnectAttempts = 0 // Reset counter on success
                } else {
                    print("⚠️ Keep-alive: Connection check failed - \(error?.localizedDescription ?? "unknown")")
                    // Don't reconnect on single failure, wait for next check
                }
            }
            
            // Additional: Subscribe to player state to keep SDK active
            self.appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
                if let error = error {
                    print("Keep-alive: Subscription refresh - \(error.localizedDescription)")
                }
            })
        }
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
        
        // Auto-reconnect immediately
        attemptReconnect()
    }
    
    private func attemptReconnect() {
        guard let token = connectionToken else {
            print("Cannot reconnect: No token available")
            return
        }
        
        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnect attempts reached. Please restart app.")
            return
        }
        
        reconnectAttempts += 1
        print("Reconnect attempt \(reconnectAttempts)/\(maxReconnectAttempts)...")
        
        // Wait briefly before reconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if !self.appRemote.isConnected {
                self.appRemote.connectionParameters.accessToken = token
                self.appRemote.connect()
            }
        }
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
