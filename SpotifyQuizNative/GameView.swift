import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Score Header
            HStack(spacing: 40) {
                VStack {
                    Text("Round")
                        .foregroundColor(.secondary)
                    Text("\(viewModel.round)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)
                
                VStack {
                    Text("Score")
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)
            }
            .padding(.top)
            
            // Timer
            if viewModel.gameState == .playing {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.3)
                        .foregroundColor(.green)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining) / 30.0)
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.green)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
                    
                    Text("\(viewModel.timeRemaining)")
                        .font(.system(size: 60, weight: .bold))
                }
                .frame(width: 150, height: 150)
                .padding()
            }
            
            // Current Track Info (when revealing answer)
            if viewModel.showAnswer {
                VStack(spacing: 10) {
                    Text("🎵")
                        .font(.system(size: 50))
                    Text(viewModel.currentTrack?.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.currentTrack?.artists ?? "Unknown Artist")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if let year = viewModel.currentTrack?.releaseYear {
                        Text("Released: \(year)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 15) {
                if viewModel.gameState == .ready {
                    Button(action: {
                        viewModel.startRound()
                    }) {
                        Text("Start Round \(viewModel.round)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                } else if viewModel.gameState == .playing {
                    HStack(spacing: 15) {
                        Button(action: {
                            viewModel.skipTrack()
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(15)
                        }
                        
                        Button(action: {
                            viewModel.revealAnswer()
                        }) {
                            Text("I Know It!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(15)
                        }
                    }
                } else if viewModel.gameState == .finished {
                    Button(action: {
                        viewModel.nextRound()
                    }) {
                        Text("Next Round")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .navigationTitle("Music Quiz")
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
    @Published var timeRemaining = 30
    @Published var gameState: GameState = .ready
    @Published var currentTrack: Track?
    @Published var showAnswer = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    var spotifyManager: SpotifyManager?
    private var timer: Timer?
    
    enum GameState {
        case ready, playing, finished
    }
    
    func startRound() {
        gameState = .playing
        showAnswer = false
        timeRemaining = 30
        
        // Fetch random track from backend
        APIManager.shared.getRandomTrack { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let track):
                    self?.currentTrack = track
                    self?.playTrack(uri: track.uri)
                    self?.startTimer()
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
        
        // Award points based on time remaining
        if timeRemaining > 20 {
            score += 3
        } else if timeRemaining > 10 {
            score += 2
        } else {
            score += 1
        }
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
                self.gameState = .finished
                self.showAnswer = true
                // Time's up - award 1 point
                self.score += 1
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
