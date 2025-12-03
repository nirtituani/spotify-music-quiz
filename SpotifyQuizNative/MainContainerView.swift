import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = true
    @State private var showConnectionScreen = false
    
    var body: some View {
        ZStack {
            // Main content - show GameModeView when connected
            if spotifyManager.isConnected {
                GameModeView()
                    .transition(.opacity)
            } else {
                // Show a placeholder while not connected
                Color(red: 0.08, green: 0.12, blue: 0.16)
                    .ignoresSafeArea()
            }
            
            // Onboarding screens
            if showWelcome && !hasSeenWelcome {
                WelcomeView(showWelcome: $showWelcome)
                    .transition(.opacity)
                    .zIndex(2)
                    .onChange(of: showWelcome) { oldValue, newValue in
                        if !newValue {
                            hasSeenWelcome = true
                        }
                    }
            }
            
            // Show connection screen whenever not connected (and welcome is done)
            if !spotifyManager.isConnected && (hasSeenWelcome || !showWelcome) {
                SpotifyConnectionView(showConnectionScreen: $showConnectionScreen)
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
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView()
            .environmentObject(SpotifyManager.shared)
    }
}
