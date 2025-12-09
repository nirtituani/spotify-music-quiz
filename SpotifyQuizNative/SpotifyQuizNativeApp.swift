import SwiftUI
import SpotifyiOS

@main
struct SpotifyQuizNativeApp: App {
    @StateObject private var spotifyManager = SpotifyManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainContainerView()
                    .environmentObject(spotifyManager)
                    .onOpenURL { url in
                        handleURL(url)
                    }
                    .onAppear {
                        print("🚀 ========================================")
                        print("🚀 APP LAUNCHED! CONSOLE IS WORKING!")
                        print("🚀 ========================================")
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
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
            // Set token for Spotify App Remote connection
            spotifyManager.setConnectionToken(accessToken)
        }
    }
    
    private func handleScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        print("🔄 App scene phase changed: \(oldPhase) -> \(newPhase)")
        
        switch newPhase {
        case .active:
            print("✅ App became active")
            // Try to reconnect if we were disconnected while in background
            spotifyManager.handleAppBecameActive()
            
        case .inactive:
            print("⏸️ App became inactive")
            // App is transitioning (e.g., opening Spotify for auth)
            // Don't disconnect - maintain connection
            
        case .background:
            print("📱 App went to background")
            // App is in background - SDK will disconnect after some time
            // This is normal behavior
            
        @unknown default:
            print("❓ Unknown scene phase")
        }
    }
}
