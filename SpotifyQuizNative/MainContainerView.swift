import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasEverConnected") private var hasEverConnected = false
    @State private var showWelcome = true
    @State private var showConnectionScreen = false
    
    var body: some View {
        ZStack {
            // Main content - show GameModeView if user has ever connected AND has valid token
            // Don't care about current connection status - we'll reconnect on-demand
            if hasEverConnected && spotifyManager.hasValidToken() {
                GameModeView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
            } else {
                // Show dark blue background for first-time users or expired token
                Color(red: 0.118, green: 0.141, blue: 0.200)
                    .ignoresSafeArea()
            }
            
            // Onboarding screens
            if showWelcome && !hasSeenWelcome {
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
            
            // Show connection screen if:
            // 1. Never connected before, OR
            // 2. Token is expired
            // BUT only show after welcome screen is done
            let needsLogin = !hasEverConnected || !spotifyManager.hasValidToken()
            let welcomeDone = hasSeenWelcome || !showWelcome
            
            if needsLogin && welcomeDone {
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
            print("   - hasEverConnected: \(hasEverConnected)")
            print("   - hasValidToken: \(spotifyManager.hasValidToken())")
            print("   - hasSeenWelcome: \(hasSeenWelcome)")
            print("   - showWelcome: \(showWelcome)")
            
            // Check if first time user
            if !hasSeenWelcome {
                showWelcome = true
                print("   → Showing Welcome screen")
            } else if !hasEverConnected || !spotifyManager.hasValidToken() {
                print("   → Should show Login screen")
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
