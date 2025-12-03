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
                // HEADER - Logo + Stats
                HStack {
                    // Beatster logo at top left - white and pink
                    HStack(spacing: 6) {
                        // Left waveform bars - 5 bars in pink
                        HStack(spacing: 2) {
                            ForEach([14, 20, 26, 20, 10], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.pink)
                                    .frame(width: 3, height: CGFloat(height))
                            }
                        }
                        
                        // Beatster text - "Beat" in white, "ster" in pink
                        HStack(spacing: 0) {
                            Text("Beat")
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .tracking(-1.5)
                                .foregroundColor(.white)
                            Text("ster")
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .tracking(-1.5)
                                .foregroundColor(.pink)
                        }
                        
                        // Right waveform bars - 5 bars in pink (mirrored)
                        HStack(spacing: 2) {
                            ForEach([10, 20, 26, 20, 14], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.pink)
                                    .frame(width: 3, height: CGFloat(height))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Stats - Streak and Coins
                    HStack(spacing: 16) {
                        // Streak
                        HStack(spacing: 6) {
                            Text("🔥")
                                .font(.system(size: 18))
                            Text("12")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Coins
                        HStack(spacing: 6) {
                            Text("💰")
                                .font(.system(size: 18))
                            Text("350")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Top section with logo and game modes
                VStack(spacing: 40) {
                    
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
                    
                    // Game Mode Buttons - 3 stacked
                    VStack(spacing: 12) {
                        // 1. Quick Play button
                        NavigationLink(destination: ContentView().environmentObject(spotifyManager)) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text("Quick Play")
                                    .font(.system(size: 18, weight: .medium))
                                
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .shadow(color: Color.pink.opacity(0.2), radius: 15, x: 0, y: 4)
                            )
                        }
                        
                        // 2. Daily Challenge button (disabled for now)
                        Button(action: {
                            // Coming soon
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text("Daily Challenge")
                                    .font(.system(size: 18, weight: .medium))
                                
                                Spacer()
                            }
                            .foregroundColor(Color.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(true)
                        
                        // 3. Multiplayer button (disabled for now)
                        Button(action: {
                            // Coming soon
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text("Multiplayer")
                                    .font(.system(size: 18, weight: .medium))
                                
                                Spacer()
                            }
                            .foregroundColor(Color.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal, 20)
                    
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
