import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasEverConnected") private var hasEverConnected = false
    
    var body: some View {
        ZStack {
            // Always show dark blue background
            Color(red: 0.118, green: 0.141, blue: 0.200)
                .ignoresSafeArea()
            
            // Determine what to show based on state
            let needsWelcome = !hasSeenWelcome
            let needsLogin = !spotifyManager.isConnected && !spotifyManager.hasValidToken()
            let showGame = spotifyManager.hasValidToken() && hasSeenWelcome
            
            // Priority 1: Welcome screen (first time users)
            if needsWelcome {
                WelcomeView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
                    .zIndex(2)
            }
            // Priority 2: Login screen (after welcome, no valid token)
            else if needsLogin {
                SpotifyConnectionView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
            // Priority 3: Game screen (has valid token and seen welcome)
            else if showGame {
                GameModeView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🔍 MainContainerView appeared")
            print("   - isConnected: \(spotifyManager.isConnected)")
            print("   - hasValidToken: \(spotifyManager.hasValidToken())")
            print("   - hasSeenWelcome: \(hasSeenWelcome)")
            
            let needsWelcome = !hasSeenWelcome
            let needsLogin = !spotifyManager.isConnected && !spotifyManager.hasValidToken()
            let showGame = spotifyManager.hasValidToken() && hasSeenWelcome
            
            print("   Decision:")
            print("   - needsWelcome: \(needsWelcome)")
            print("   - needsLogin: \(needsLogin)")
            print("   - showGame: \(showGame)")
            
            if needsWelcome {
                print("   → Showing Welcome screen")
            } else if needsLogin {
                print("   → Showing Login screen")
            } else {
                print("   → Showing Game screen")
            }
        }
        .onChange(of: spotifyManager.isConnected) { oldValue, newValue in
            // Mark as connected once user successfully connects
            if newValue {
                hasEverConnected = true
                print("✓ User has successfully connected to Spotify")
            }
        }
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView()
            .environmentObject(SpotifyManager.shared)
    }
}
