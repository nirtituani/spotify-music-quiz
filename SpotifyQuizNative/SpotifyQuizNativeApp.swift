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
        // Spotify SDK handles the OAuth callback internally
        // We just need to trigger the connection
        print("Received callback URL: \(url)")
        
        // The SDK will automatically connect after authorization
        // Extract access token if needed for backend API calls
        let parameters = url.fragment?.components(separatedBy: "&").reduce(into: [String: String]()) { result, param in
            let parts = param.components(separatedBy: "=")
            if parts.count == 2 {
                result[parts[0]] = parts[1]
            }
        }
        
        if let accessToken = parameters?["access_token"] {
            print("Access token received: \(accessToken.prefix(10))...")
            // Store token for backend API calls
            APIManager.shared.setAccessToken(accessToken)
        }
    }
}
