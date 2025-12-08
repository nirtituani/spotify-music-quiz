import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @StateObject private var viewModel: GameViewModel
    
    let playlistId: String?
    let duration: Int
    let playlistName: String
    
    init(playlistId: String? = nil, duration: Int = 30, playlistName: String = "Random from Spotify") {
        self.playlistId = playlistId
        self.duration = duration
        self.playlistName = playlistName
        self._viewModel = StateObject(wrappedValue: GameViewModel(playlistId: playlistId, duration: duration))
    }
    
    var body: some View {
        ZStack {
            // Dark blue/navy background
            Color(red: 0.118, green: 0.141, blue: 0.200)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with Beatster logo and stats
                HStack {
                    // Beatster logo (small version)
                    HStack(spacing: 1) {
                        HStack(spacing: 1.5) {
                            ForEach([4, 8, 12, 8, 4], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color(red: 1.0, green: 0.0, blue: 0.4))
                                    .frame(width: 2, height: CGFloat(height))
                            }
                        }
                        
                        HStack(spacing: 0) {
                            Text("Beat")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                            Text("ster")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                        }
                        
                        HStack(spacing: 1.5) {
                            ForEach([4, 8, 12, 8, 4], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color(red: 1.0, green: 0.0, blue: 0.4))
                                    .frame(width: 2, height: CGFloat(height))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Round and Score
                    HStack(spacing: 20) {
                        VStack(spacing: 2) {
                            Text("Round")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(viewModel.round)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 2) {
                            Text("Score")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(viewModel.score)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
            
            // Playlist Name
            HStack(spacing: 8) {
                Image(systemName: "music.note.list")
                    .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                Text(playlistName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Timer (only show if not Full Song mode)
            if viewModel.gameState == .playing && viewModel.duration > 0 {
                ZStack {
                    // Outer glow - changes to red when ≤5 seconds
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    (viewModel.timeRemaining <= 5 ? Color.red : Color(red: 1.0, green: 0.0, blue: 0.4)).opacity(0.4),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 60,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .scaleEffect(viewModel.timeRemaining <= 5 ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.timeRemaining <= 5)
                    
                    // Background circle
                    Circle()
                        .stroke(lineWidth: 12)
                        .opacity(0.2)
                        .foregroundColor(viewModel.timeRemaining <= 5 ? Color.red : Color(red: 1.0, green: 0.0, blue: 0.4))
                    
                    // Progress circle - turns red when ≤5 seconds
                    Circle()
                        .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining) / CGFloat(viewModel.duration))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: viewModel.timeRemaining <= 5 ? [
                                    Color.red,
                                    Color(red: 1.0, green: 0.3, blue: 0.3)
                                ] : [
                                    Color(red: 1.0, green: 0.0, blue: 0.4),
                                    Color(red: 1.0, green: 0.1, blue: 0.45)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
                        .shadow(color: (viewModel.timeRemaining <= 5 ? Color.red : Color(red: 1.0, green: 0.0, blue: 0.4)).opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    // Timer text - larger and red when ≤5 seconds
                    Text("\(viewModel.timeRemaining)")
                        .font(.system(size: viewModel.timeRemaining <= 5 ? 72 : 64, weight: .bold))
                        .foregroundColor(viewModel.timeRemaining <= 5 ? Color.red : .white)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.timeRemaining)
                }
                .frame(width: 160, height: 160)
                .padding()
                .scaleEffect(viewModel.timeRemaining <= 5 ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.timeRemaining <= 5)
            } else if viewModel.gameState == .playing && viewModel.duration == 0 {
                // Full Song mode - show playing indicator
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                    }
                    
                    Text("Playing Full Song")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Press 'I Know It!' when ready")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
            }
            
            Spacer()
            
            // Current Track Info (when revealing answer)
            if viewModel.showAnswer {
                VStack(spacing: 12) {
                    Text("🎵")
                        .font(.system(size: 60))
                    
                    Text(viewModel.currentTrack?.name ?? "Unknown")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(viewModel.currentTrack?.artists ?? "Unknown Artist")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.4))
                        .multilineTextAlignment(.center)
                    
                    if let year = viewModel.currentTrack?.releaseYear {
                        Text("Released: \(year)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.15, green: 0.18, blue: 0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.2), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 20)
            }
            
            // Action Buttons
            VStack(spacing: 15) {
                if viewModel.gameState == .ready {
                    Button(action: {
                        viewModel.startRound()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Start Round \(viewModel.round)")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.0, blue: 0.4),
                                    Color(red: 1.0, green: 0.1, blue: 0.45)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3), radius: 15, x: 0, y: 5)
                    }
                } else if viewModel.gameState == .playing {
                    VStack(spacing: 15) {
                        // Show "Add 30 Seconds" button when ≤5 seconds
                        if viewModel.timeRemaining <= 5 && viewModel.duration > 0 {
                            Button(action: {
                                viewModel.extendTime()
                            }) {
                                HStack {
                                    Image(systemName: "clock.badge.plus.fill")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Add 30 Seconds")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange,
                                            Color(red: 1.0, green: 0.6, blue: 0.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: 5)
                            }
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                viewModel.skipTrack()
                            }) {
                                HStack {
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Skip")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.15, green: 0.18, blue: 0.25))
                                .cornerRadius(28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            Button(action: {
                                viewModel.revealAnswer()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("I Know It!")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.0, blue: 0.4),
                                            Color(red: 1.0, green: 0.1, blue: 0.45)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3), radius: 15, x: 0, y: 5)
                            }
                        }
                    }
                } else if viewModel.gameState == .waitingForReveal {
                    Button(action: {
                        viewModel.revealAfterTimeout()
                    }) {
                        HStack {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text("Reveal")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.0, blue: 0.4),
                                    Color(red: 1.0, green: 0.1, blue: 0.45)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3), radius: 15, x: 0, y: 5)
                    }
                } else if viewModel.gameState == .finished {
                    Button(action: {
                        viewModel.nextRound()
                    }) {
                        HStack {
                            Text("Next Round")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.0, blue: 0.4),
                                    Color(red: 1.0, green: 0.1, blue: 0.45)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.4).opacity(0.3), radius: 15, x: 0, y: 5)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            viewModel.spotifyManager = spotifyManager
        }
    }
}

// MARK: - View Model

class GameViewModel: ObservableObject {
    @Published var round = 1
    @Published var score = 0
    @Published var timeRemaining: Int
    @Published var gameState: GameState = .ready
    @Published var currentTrack: Track?
    @Published var showAnswer = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    var spotifyManager: SpotifyManager?
    private var timer: Timer?
    private let playlistId: String?
    let duration: Int
    
    init(playlistId: String? = nil, duration: Int = 30) {
        self.playlistId = playlistId
        self.duration = duration
        self.timeRemaining = duration
    }
    
    enum GameState {
        case ready, playing, waitingForReveal, finished
    }
    
    func startRound() {
        gameState = .playing
        showAnswer = false
        timeRemaining = duration
        
        // Fetch random track from backend with optional playlist
        APIManager.shared.getRandomTrack(playlistId: playlistId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let track):
                    self?.currentTrack = track
                    self?.playTrack(uri: track.uri)
                    // Only start timer if not Full Song mode (duration > 0)
                    if let duration = self?.duration, duration > 0 {
                        self?.startTimer()
                    }
                case .failure(let error):
                    self?.showError(message: "Failed to fetch track: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func skipTrack() {
        stopTimer()
        spotifyManager?.pause()
        gameState = .finished
        showAnswer = true
        // No points for skipping
    }
    
    func revealAnswer() {
        stopTimer()
        spotifyManager?.pause()
        gameState = .finished
        showAnswer = true
        
        // Award points based on time remaining (only for timed modes)
        if duration > 0 {
            if timeRemaining > 20 {
                score += 3
            } else if timeRemaining > 10 {
                score += 2
            } else {
                score += 1
            }
        } else {
            // Full Song mode - fixed points
            score += 2
        }
    }
    
    func extendTime() {
        // Add 30 seconds to the timer
        timeRemaining += 30
        print("Extended time by 30 seconds. New time: \(timeRemaining)")
    }
    
    func revealAfterTimeout() {
        gameState = .finished
        showAnswer = true
        // Time's up - award 1 point
        score += 1
    }
    
    func nextRound() {
        round += 1
        gameState = .ready
        showAnswer = false
    }
    
    private func playTrack(uri: String) {
        spotifyManager?.playTrack(uri: uri)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.spotifyManager?.pause()
                self.gameState = .waitingForReveal
                // Don't show answer yet - wait for user to click Reveal
                // Award 1 point when revealed
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        gameState = .ready
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(SpotifyManager.shared)
    }
}
