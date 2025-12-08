import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasEverConnected") private var hasEverConnected = false
    @State private var showWelcome = true
    @State private var showConnectionScreen = false
    
    var body: some View {
        ZStack {
            // Main content - show GameModeView when connected OR if reconnecting
            if spotifyManager.isConnected || (spotifyManager.isReconnecting && hasEverConnected) {
                GameModeView()
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
            } else {
                // Show dark blue background when not connected
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
            
            // Show connection screen when not connected AND not reconnecting (after welcome is done)
            if !spotifyManager.isConnected && !spotifyManager.isReconnecting && (hasSeenWelcome || !showWelcome) {
                SpotifyConnectionView(showConnectionScreen: $showConnectionScreen)
                    .environmentObject(spotifyManager)
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            // Show reconnecting indicator when reconnecting
            if spotifyManager.isReconnecting && hasEverConnected {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(red: 1.0, green: 0.0, blue: 0.4))
                    
                    Text("Reconnecting to Spotify...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.118, green: 0.141, blue: 0.200).opacity(0.95))
                .zIndex(3)
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
