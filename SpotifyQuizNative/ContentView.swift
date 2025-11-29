import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var selectedPlaylist = "random"
    @State private var selectedDuration = 30
    @State private var userPlaylists: [Playlist] = []
    
    let durations = [30, 60]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🎵")
                            .font(.system(size: 60))
                        Text("Spotify Music Quiz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Guess the song!")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                    .padding(.top)
                    
                    // Connection Status
                    HStack {
                        Circle()
                            .fill(spotifyManager.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(spotifyManager.isConnected ? "Connected to Spotify" : "Not Connected")
                            .foregroundColor(.secondary)
                    }
                    
                    // Login/Settings Section
                    if !spotifyManager.isConnected {
                        VStack(spacing: 20) {
                            Text("Login Required")
                                .font(.headline)
                            
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
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(15)
                            }
                        }
                        .padding()
                    } else {
                        // Game Settings
                        VStack(spacing: 25) {
                            // Playlist Selector
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Select Playlist")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    Button(action: { selectedPlaylist = "random" }) {
                                        Label("Random from Spotify", systemImage: "shuffle")
                                    }
                                    
                                    if !userPlaylists.isEmpty {
                                        Divider()
                                        ForEach(userPlaylists, id: \.id) { playlist in
                                            Button(action: { selectedPlaylist = playlist.id }) {
                                                Text(playlist.name)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(getPlaylistName())
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Duration Selector
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Song Duration")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 15) {
                                    ForEach(durations, id: \.self) { duration in
                                        Button(action: {
                                            selectedDuration = duration
                                        }) {
                                            Text("\(duration) sec")
                                                .font(.subheadline)
                                                .fontWeight(selectedDuration == duration ? .bold : .regular)
                                                .foregroundColor(selectedDuration == duration ? .white : .primary)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(selectedDuration == duration ? Color.green : Color.green.opacity(0.1))
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            
                            // Start Game Button
                            NavigationLink(destination: GameView(playlistId: selectedPlaylist == "random" ? nil : selectedPlaylist, duration: selectedDuration)) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Start Game")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(15)
                            }
                        }
                        .padding()
                    }
                    
                    // Info
                    Text("Requires Spotify Premium")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .onAppear {
                if spotifyManager.isConnected {
                    loadUserPlaylists()
                }
            }
        }
    }
    
    private func getPlaylistName() -> String {
        if selectedPlaylist == "random" {
            return "Random from Spotify"
        }
        return userPlaylists.first(where: { $0.id == selectedPlaylist })?.name ?? "Random from Spotify"
    }
    
    private func loadUserPlaylists() {
        print("Loading user playlists...")
        APIManager.shared.getUserPlaylists { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    print("Successfully loaded \(playlists.count) playlists")
                    self.userPlaylists = playlists
                case .failure(let error):
                    print("Failed to load playlists: \(error.localizedDescription)")
                    print("Error details: \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SpotifyManager.shared)
    }
}
