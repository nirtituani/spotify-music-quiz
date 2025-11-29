import Foundation
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
    
    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        config.playURI = ""
        config.tokenSwapURL = URL(string: "")
        config.tokenRefreshURL = URL(string: "")
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
        connect()
    }
    
    /// Disconnect from Spotify
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    /// Authorize with Spotify (OAuth)
    func authorize() {
        let requestedScopes = ["app-remote-control", "user-read-private", "playlist-read-private"]
        
        appRemote.authorizeAndPlayURI("", asRadio: false, additionalScopes: requestedScopes) { [weak self] success in
            if success {
                print("Authorization successful")
                // Try to connect after a short delay to let Spotify app settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.connect()
                    // Retry connection if it fails
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if !(self?.appRemote.isConnected ?? false) {
                            print("Retrying connection...")
                            self?.connect()
                        }
                    }
                }
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
        
        // Subscribe to player state
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("App Remote connection failed: \(error?.localizedDescription ?? "unknown error")")
        isConnected = false
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("App Remote disconnected: \(error?.localizedDescription ?? "no error")")
        isConnected = false
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
