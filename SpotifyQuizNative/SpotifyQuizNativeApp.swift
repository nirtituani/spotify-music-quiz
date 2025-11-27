import SwiftUI
import SpotifyiOS

@main
struct SpotifyQuizNativeApp: App {
    @StateObject private var spotifyManager = SpotifyManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotifyManager)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    private func handleURL(_ url: URL) {
        // Handle Spotify OAuth callback
        let parameters = url.fragment?.components(separatedBy: "&").reduce(into: [String: String]()) { result, param in
            let parts = param.components(separatedBy: "=")
            if parts.count == 2 {
                result[parts[0]] = parts[1]
            }
        }
        
        if let accessToken = parameters?["access_token"] {
            spotifyManager.setAccessToken(accessToken)
            APIManager.shared.setAccessToken(accessToken)
        }
    }
}
