import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = true
    @State private var showConnectionScreen = false
    @State private var selectedPlaylist = "random"
    @State private var selectedDuration = 30
    @State private var userPlaylists: [Playlist] = []
    
    let durations = [30, 60, 0] // 0 = Full Song
    
    // Curated playlists matching web version
    let curatedPlaylists: [(id: String, name: String, category: String)] = [
        // Decades
        ("60s", "🎸 60s Hits", "Decades"),
        ("70s", "🕺 70s Classics", "Decades"),
        ("80s", "🎹 80s Pop", "Decades"),
        ("90s", "💿 90s Favorites", "Decades"),
        ("2000s", "📱 2000s Hits", "Decades"),
        ("2010s", "🎧 2010s Pop", "Decades"),
        ("2020s", "🎵 2020s Chart", "Decades"),
        // Genres
        ("rock", "🎸 Rock", "Genres"),
        ("pop", "🎤 Pop", "Genres"),
        ("hiphop", "🎤 Hip Hop", "Genres"),
        ("electronic", "🎹 Electronic", "Genres"),
        ("jazz", "🎺 Jazz", "Genres"),
        ("classical", "🎻 Classical", "Genres"),
        ("country", "🤠 Country", "Genres"),
        ("rnb", "🎵 R&B", "Genres"),
        ("metal", "🤘 Metal", "Genres"),
        ("indie", "🎸 Indie", "Genres"),
        // Themes
        ("movie", "🎬 Movie Soundtracks", "Themes"),
        ("disney", "🏰 Disney", "Themes"),
        ("workout", "💪 Workout", "Themes"),
        ("chill", "😌 Chill/Relax", "Themes"),
        ("party", "🎉 Party", "Themes"),
        ("sad", "😢 Sad Songs", "Themes"),
        // Regional
        ("israeli", "🇮🇱 Israeli Music", "Regional"),
        ("latin", "💃 Latin", "Regional"),
        ("kpop", "🇰🇷 K-Pop", "Regional"),
    ]
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                VStack(spacing: 30) {
                    // Only show main menu if connected
                    if spotifyManager.isConnected {
                        // Header
                        VStack(spacing: 10) {
                            Text("🎵")
                                .font(.system(size: 60))
                            Text("Beatster")
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
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text("Connected to Spotify")
                                .foregroundColor(.secondary)
                        }
                        
                        // Game Settings
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
                                    
                                    // Group curated playlists by category
                                    ForEach(["Decades", "Genres", "Themes", "Regional"], id: \.self) { category in
                                        Section(header: Text(category)) {
                                            ForEach(curatedPlaylists.filter { $0.category == category }, id: \.id) { playlist in
                                                Button(action: { selectedPlaylist = playlist.id }) {
                                                    Text(playlist.name)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if !userPlaylists.isEmpty {
                                        Divider()
                                        Section(header: Text("Your Playlists")) {
                                            ForEach(userPlaylists, id: \.id) { playlist in
                                                Button(action: { selectedPlaylist = playlist.id }) {
                                                    Text(playlist.name)
                                                }
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
                                            Text(duration == 0 ? "Full Song" : "\(duration) sec")
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
                            NavigationLink(destination: GameView(playlistId: getPlaylistIdForBackend(), duration: selectedDuration, playlistName: getPlaylistName())) {
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
                        
                        // Info
                        Text("Requires Spotify Premium")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal)
            }
                .navigationBarHidden(true)
                .onAppear {
                    print("ContentView appeared, isConnected: \(spotifyManager.isConnected)")
                    
                    // Check if first time user
                    if !hasSeenWelcome {
                        showWelcome = true
                    } else if !spotifyManager.isConnected {
                        // If returning user but not connected, show connection screen
                        showConnectionScreen = true
                    }
                    
                    if spotifyManager.isConnected {
                        loadUserPlaylists()
                    }
                }
                .onChange(of: spotifyManager.isConnected) { isConnected in
                    print("Connection status changed to: \(isConnected)")
                    if isConnected {
                        loadUserPlaylists()
                    }
                }
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
    }
    
    private func getPlaylistName() -> String {
        if selectedPlaylist == "random" {
            return "Random from Spotify"
        }
        // Check curated playlists first
        if let curated = curatedPlaylists.first(where: { $0.id == selectedPlaylist }) {
            return curated.name
        }
        // Then check user playlists
        return userPlaylists.first(where: { $0.id == selectedPlaylist })?.name ?? "Random from Spotify"
    }
    
    private func getPlaylistIdForBackend() -> String? {
        if selectedPlaylist == "random" {
            return nil
        }
        // Check if it's a curated playlist - add genre: prefix
        if curatedPlaylists.contains(where: { $0.id == selectedPlaylist }) {
            return "genre:\(selectedPlaylist)"
        }
        // User playlist - return as is
        return selectedPlaylist
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
