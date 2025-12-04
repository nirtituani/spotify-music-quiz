import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
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
            // Dark blue/navy background
            Color(red: 0.118, green: 0.141, blue: 0.200)
                .ignoresSafeArea()
            
            NavigationView {
                ScrollView {
                VStack(spacing: 30) {
                    // Only show main menu if connected
                    if spotifyManager.isConnected {
                        // Header with Beatster logo
                        VStack(spacing: 15) {
                            HStack(spacing: 2) {
                                // Left waveform bars
                                HStack(spacing: 2) {
                                    ForEach([6, 13, 23, 34, 19, 5], id: \.self) { height in
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(Color(red: 1.0, green: 0.0, blue: 0.4))
                                            .frame(width: 3, height: CGFloat(height))
                                    }
                                }
                                
                                // Beatster text
                                HStack(spacing: 0) {
                                    Text("Beat")
                                        .font(.system(size: 38, weight: .heavy))
                                        .tracking(-0.5)
                                        .foregroundColor(.white)
                                    Text("ster")
                                        .font(.system(size: 38, weight: .heavy))
                                        .tracking(-0.5)
                                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                                }
                                
                                // Right waveform bars
                                HStack(spacing: 2) {
                                    ForEach([5, 19, 34, 23, 11, 5], id: \.self) { height in
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(Color(red: 1.0, green: 0.0, blue: 0.4))
                                            .frame(width: 3, height: CGFloat(height))
                                    }
                                }
                            }
                            
                            Text("Choose Your Music")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 60)
                        
                        // Connection Status
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.0, blue: 0.4))
                                .frame(width: 8, height: 8)
                            Text("Connected to Spotify")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 5)
                        
                        // Game Settings
                        VStack(spacing: 25) {
                            // Playlist Selector
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Playlist")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
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
                                        Image(systemName: "music.note.list")
                                            .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                                        Text(getPlaylistName())
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.15, green: 0.18, blue: 0.25))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            
                            // Duration Selector
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Song Duration")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    ForEach(durations, id: \.self) { duration in
                                        Button(action: {
                                            selectedDuration = duration
                                        }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: duration == 0 ? "infinity" : "timer")
                                                    .font(.system(size: 20))
                                                Text(duration == 0 ? "Full" : "\(duration)s")
                                                    .font(.system(size: 14, weight: .semibold))
                                            }
                                            .foregroundColor(selectedDuration == duration ? .white : .white.opacity(0.6))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 70)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(
                                                        selectedDuration == duration ?
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color(red: 1.0, green: 0.0, blue: 0.4),
                                                                Color(red: 1.0, green: 0.1, blue: 0.45)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ) :
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color(red: 0.15, green: 0.18, blue: 0.25),
                                                                Color(red: 0.15, green: 0.18, blue: 0.25)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(
                                                                selectedDuration == duration ?
                                                                Color(red: 1.0, green: 0.0, blue: 0.4) :
                                                                Color.white.opacity(0.2),
                                                                lineWidth: selectedDuration == duration ? 2 : 1
                                                            )
                                                    )
                                            )
                                            .shadow(
                                                color: selectedDuration == duration ?
                                                Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3) :
                                                Color.clear,
                                                radius: 10,
                                                x: 0,
                                                y: 5
                                            )
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Start Game Button
                            NavigationLink(destination: GameView(playlistId: getPlaylistIdForBackend(), duration: selectedDuration, playlistName: getPlaylistName()).environmentObject(spotifyManager)) {
                                ZStack {
                                    HStack(spacing: 16) {
                                        // Play icon in black circle button (left side)
                                        ZStack {
                                            // Deeper outer shadow for stronger 3D effect
                                            Circle()
                                                .fill(Color.black.opacity(0.7))
                                                .frame(width: 52, height: 52)
                                                .blur(radius: 6)
                                                .offset(x: 0, y: 3)
                                            
                                            // Inner shadow layer
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .frame(width: 50, height: 50)
                                                .blur(radius: 2)
                                                .offset(x: 0, y: 1)
                                            
                                            // Main black circle with gradient for depth
                                            Circle()
                                                .fill(
                                                    RadialGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 0.18, green: 0.18, blue: 0.18),
                                                            Color.black
                                                        ]),
                                                        center: .center,
                                                        startRadius: 5,
                                                        endRadius: 25
                                                    )
                                                )
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                                )
                                            
                                            // Bottom inner shadow (pressed effect)
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.clear,
                                                            Color.black.opacity(0.3)
                                                        ]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(width: 48, height: 48)
                                            
                                            // Top highlight
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.white.opacity(0.15),
                                                            Color.clear
                                                        ]),
                                                        startPoint: .top,
                                                        endPoint: .center
                                                    )
                                                )
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                                                .offset(x: 2, y: 0)
                                                .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.5), radius: 4, x: 0, y: 0)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 10)
                                    
                                    // Centered "Start Game" text
                                    Text("Start Game")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 320, height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(Color(red: 0.15, green: 0.18, blue: 0.22))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 35)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.0, blue: 0.4),
                                                    Color(red: 1.0, green: 0.1, blue: 0.45)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.2), radius: 10, x: 0, y: 3)
                                .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.1), radius: 20, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Info
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text("Requires Spotify Premium")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 40)
                    }
                }
                .padding(.horizontal)
            }
                .navigationBarHidden(true)
                .onAppear {
                    print("ContentView appeared, isConnected: \(spotifyManager.isConnected)")
                    
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
