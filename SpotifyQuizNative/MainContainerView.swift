import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasEverConnected") private var hasEverConnected = false
    @State private var showWelcome = true
    @State private var showConnectionScreen = false
    
    var body: some View {
        ZStack {
            // Determine what to show based on state
            let needsWelcome = !hasSeenWelcome
            let needsLogin = !spotifyManager.isConnected && !spotifyManager.hasValidToken()
            let showGame = spotifyManager.hasValidToken() && hasSeenWelcome
            
            // Main content - show GameModeView only if welcome is done and we have token
            if showGame {
                GameModeView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
            } else {
                // Show dark blue background
                Color(red: 0.118, green: 0.141, blue: 0.200)
                    .ignoresSafeArea()
            }
            
            // Onboarding screens - Priority 1: Welcome screen
            if showWelcome && needsWelcome {
                WelcomeView(showWelcome: $showWelcome)
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
                    .zIndex(2)
                    .onChange(of: showWelcome) { oldValue, newValue in
                        if !newValue {
                            hasSeenWelcome = true
                        }
                    }
            }
            
            // Priority 2: Login screen (after welcome is done)
            if needsLogin && hasSeenWelcome {
                SpotifyConnectionView(showConnectionScreen: $showConnectionScreen)
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🔍 MainContainerView appeared")
            print("   - isConnected: \(spotifyManager.isConnected)")
            print("   - hasValidToken: \(spotifyManager.hasValidToken())")
            print("   - hasSeenWelcome: \(hasSeenWelcome)")
            print("   - showWelcome: \(showWelcome)")
            
            let needsWelcome = !hasSeenWelcome
            let needsLogin = !spotifyManager.isConnected && !spotifyManager.hasValidToken()
            let showGame = spotifyManager.hasValidToken() && hasSeenWelcome
            
            print("   Decision:")
            print("   - needsWelcome: \(needsWelcome)")
            print("   - needsLogin: \(needsLogin)")
            print("   - showGame: \(showGame)")
            
            // Check if first time user
            if needsWelcome {
                showWelcome = true
                print("   → Showing Welcome screen first")
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
