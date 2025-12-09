import SwiftUI

struct SpotifyConnectionView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.2, blue: 0.25),
                    Color(red: 0.1, green: 0.25, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("Connect with Spotify")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text("Access with Spotify to access the music you can access to access to your music.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Connect with Spotify button
                    Button(action: {
                        print("✓ User clicked 'Connect with Spotify' - starting authorization")
                        spotifyManager.authorize()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text("Connect with Spotify")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color(red: 0.11, green: 0.93, blue: 0.53)) // Spotify green
                        )
                        .shadow(color: Color(red: 0.11, green: 0.93, blue: 0.53).opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 80)
            }
        }
    }
}

struct SpotifyConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyConnectionView()
            .environmentObject(SpotifyManager.shared)
    }
}
