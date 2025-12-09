import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasEverConnected") private var hasEverConnected = false
    @State private var showWelcome = true
    @State private var showConnectionScreen = false
    
    var body: some View {
        ZStack {
            // Main content - show GameModeView if user has ever connected
            // Don't care about current connection status - we'll reconnect on-demand
            if hasEverConnected {
                GameModeView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
            } else {
                // Show dark blue background for first-time users
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
            
            // Show connection screen only if never connected before (after welcome is done)
            if !hasEverConnected && (hasSeenWelcome || !showWelcome) {
                SpotifyConnectionView(showConnectionScreen: $showConnectionScreen)
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("MainContainerView appeared, isConnected: \(spotifyManager.isConnected)")
            
            // Check if first time user
            if !hasSeenWelcome {
                showWelcome = true
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
