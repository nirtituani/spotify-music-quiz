import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var showGame = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("🎵")
                        .font(.system(size: 80))
                    Text("Spotify Music Quiz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Guess the song in 30 seconds!")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Connection Status
                HStack {
                    Circle()
                        .fill(spotifyManager.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(spotifyManager.isConnected ? "Connected to Spotify" : "Not Connected")
                        .foregroundColor(.secondary)
                }
                
                // Main Action Button
                if !spotifyManager.isConnected {
                    Button(action: {
                        spotifyManager.authorize()
                    }) {
                        HStack {
                            Image(systemName: "music.note")
                            Text("Login with Spotify")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                } else {
                    NavigationLink(destination: GameView()) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Start Game")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                }
                
                Spacer()
                
                // Info
                Text("Requires Spotify Premium")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SpotifyManager.shared)
    }
}
