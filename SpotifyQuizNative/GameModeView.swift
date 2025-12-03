import SwiftUI

struct GameModeView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var pulseAnimation = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Dark background - #0F0F12
            Color(red: 0.059, green: 0.059, blue: 0.071)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with logo and game modes
                VStack(spacing: 40) {
                    // Beatster logo at top center - all white with correct waveform pattern
                    HStack(spacing: 12) {
                        // Left waveform bars - 6 bars: builds toward text [6, 10, 14, 18, 14, 10]
                        HStack(spacing: 3) {
                            ForEach([6, 10, 14, 18, 14, 10], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 3, height: CGFloat(height))
                            }
                        }
                        
                        // Beatster text - all white
                        Text("Beatster")
                            .font(.system(size: 30, weight: .bold))
                            .tracking(-0.5)
                            .foregroundColor(.white)
                            .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 0)
                            .shadow(color: Color.pink.opacity(0.15), radius: 20, x: 0, y: 0)
                        
                        // Right waveform bars - 6 bars: descends from text [10, 14, 18, 14, 10, 6]
                        HStack(spacing: 3) {
                            ForEach([10, 14, 18, 14, 10, 6], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 3, height: CGFloat(height))
                            }
                        }
                    }
                    .padding(.top, 60)
                    
                    // Large circular B logo with glow
                    ZStack {
                        // Outer glow circles
                        Circle()
                            .stroke(
                                Color.pink.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 240, height: 240)
                            .blur(radius: 10)
                        
                        Circle()
                            .stroke(
                                Color.pink.opacity(0.4),
                                lineWidth: 3
                            )
                            .frame(width: 220, height: 220)
                            .blur(radius: 8)
                        
                        // Main glowing circle
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.pink,
                                        Color(red: 1.0, green: 0.3, blue: 0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 200, height: 200)
                            .shadow(color: Color.pink.opacity(0.8), radius: 30, x: 0, y: 0)
                            .shadow(color: Color.pink.opacity(0.6), radius: 50, x: 0, y: 0)
                            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )
                        
                        // B logo with waveform
                        HStack(spacing: 2) {
                            // Left waveform bars
                            VStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.pink)
                                        .frame(width: 2, height: 20)
                                }
                            }
                            
                            // B letter
                            Text("B")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.pink)
                            
                            // Right waveform bars
                            VStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.pink)
                                        .frame(width: 2, height: 20)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 30)
                    
                    // Quick Play button
                    NavigationLink(destination: ContentView().environmentObject(spotifyManager)) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("Quick Play")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.pink,
                                            Color(red: 1.0, green: 0.3, blue: 0.6)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.pink.opacity(0.5), radius: 20, x: 0, y: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.pink.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    // Multiplayer button (disabled for now)
                    Button(action: {
                        // Coming soon
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("Multiplayer")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(width: 280, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(red: 0.15, green: 0.18, blue: 0.22))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .disabled(true)
                    
                    Spacer()
                }
                
                // Bottom navigation bar
                HStack(spacing: 0) {
                    // Home
                    TabBarButton(
                        icon: "house.fill",
                        label: "Home",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    // Leaderboard
                    TabBarButton(
                        icon: "chart.bar.fill",
                        label: "Leaderboard",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                    
                    // Profile
                    TabBarButton(
                        icon: "person.fill",
                        label: "Profile",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                    
                    // Settings
                    TabBarButton(
                        icon: "gearshape.fill",
                        label: "Settings",
                        isSelected: selectedTab == 3
                    ) {
                        selectedTab = 3
                    }
                }
                .frame(height: 80)
                .background(Color(red: 0.10, green: 0.14, blue: 0.18))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.white.opacity(0.1)),
                    alignment: .top
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            pulseAnimation = true
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .pink : Color.white.opacity(0.5))
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .pink : Color.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct GameModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameModeView()
                .environmentObject(SpotifyManager.shared)
        }
    }
}
