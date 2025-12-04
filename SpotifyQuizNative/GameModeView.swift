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
                    // Beatster logo at top center - white "Beat" + pink "ster" with waveform
                    HStack(spacing: 2) {
                        // Left waveform bars - 6 bars, very close to "B": [6, 13, 23, 34, 19, 5]
                        HStack(spacing: 2) {
                            ForEach([6, 13, 23, 34, 19, 5], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.pink)
                                    .frame(width: 3, height: CGFloat(height))
                            }
                        }
                        
                        // Beatster text - "Beat" white, "ster" pink
                        HStack(spacing: 0) {
                            Text("Beat")
                                .font(.system(size: 32, weight: .heavy))
                                .tracking(-0.5)
                                .foregroundColor(.white)
                            Text("ster")
                                .font(.system(size: 32, weight: .heavy))
                                .tracking(-0.5)
                                .foregroundColor(.pink)
                        }
                        
                        // Right waveform bars - 6 bars, very close to "r": [5, 19, 34, 23, 11, 5]
                        HStack(spacing: 2) {
                            ForEach([5, 19, 34, 23, 11, 5], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.pink)
                                    .frame(width: 3, height: CGFloat(height))
                            }
                        }
                    }
                    .padding(.top, 60)
                    
                    // Central emblem with 'B' logo and integrated waveform
                    ZStack {
                        // Layer 1: Outer glow effect (most outer blur)
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.6),
                                        Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 140
                                )
                            )
                            .frame(width: 280, height: 280)
                            .blur(radius: 40)
                        
                        // Layer 2: Inner glow circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.5),
                                        Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.2),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 220, height: 220)
                            .blur(radius: 25)
                        
                        // Layer 3: Outer pink ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.4),
                                        Color(red: 1.0, green: 0.3, blue: 0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 200, height: 200)
                            .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.6), radius: 20, x: 0, y: 0)
                        
                        // Layer 4: Inner pink ring
                        Circle()
                            .stroke(
                                Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.4),
                                lineWidth: 2
                            )
                            .frame(width: 170, height: 170)
                        
                        // Layer 5: Dark center fill
                        Circle()
                            .fill(Color(red: 0.059, green: 0.059, blue: 0.071))
                            .frame(width: 166, height: 166)
                        
                        // Layer 6: 'B' letter (outlined/hollow) with integrated waveform bars
                        ZStack {
                            // Hollow/Outlined 'B' letter using stroke
                            Text("B")
                                .font(.system(size: 80, weight: .heavy))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.2, blue: 0.4),
                                            Color(red: 1.0, green: 0.3, blue: 0.5)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    // Create the hollow effect by masking the center
                                    Text("B")
                                        .font(.system(size: 80, weight: .heavy))
                                        .foregroundColor(Color(red: 0.059, green: 0.059, blue: 0.071))
                                        .scaleEffect(0.85) // Slightly smaller to create stroke effect
                                )
                            
                            // Waveform bars integrated into the 'B' (left side of B)
                            HStack(spacing: 3) {
                                ForEach([12, 18, 24, 18, 12], id: \.self) { height in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.2, blue: 0.4),
                                                    Color(red: 1.0, green: 0.3, blue: 0.5)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 3, height: CGFloat(height))
                                }
                            }
                            .offset(x: -18, y: 0) // Position bars on left side of 'B'
                        }
                    }
                    .padding(.vertical, 30)
                    
                    // Quick Play button
                    NavigationLink(destination: ContentView().environmentObject(spotifyManager)) {
                        HStack(spacing: 16) {
                            // Play icon in circle
                            ZStack {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.2, blue: 0.4))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: 2, y: 0) // Slight offset to center the play triangle
                            }
                            
                            Text("Quick Play")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.leading, 8)
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
                                            Color(red: 1.0, green: 0.2, blue: 0.4),
                                            Color(red: 1.0, green: 0.3, blue: 0.5)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.4), radius: 15, x: 0, y: 5)
                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.2), radius: 30, x: 0, y: 10)
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
