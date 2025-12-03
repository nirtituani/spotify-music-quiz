import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var waveformAnimation = false
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.15, blue: 0.25),
                    Color(red: 0.1, green: 0.2, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Beatster logo with waveform
                VStack(spacing: 20) {
                    // Animated waveform
                    HStack(spacing: 3) {
                        ForEach(0..<30, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.cyan.opacity(0.6),
                                            Color.cyan
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 3, height: waveformHeight(for: index))
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.05),
                                    value: waveformAnimation
                                )
                        }
                    }
                    .frame(height: 80)
                    
                    // Beatster title with neon glow
                    Text("Beatster")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan,
                                    Color(red: 0.3, green: 0.9, blue: 0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.8), radius: 20, x: 0, y: 0)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 40, x: 0, y: 0)
                }
                
                // Tagline
                Text("Guess the beat, feel the rhythm")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showWelcome = false
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.cyan,
                                            Color(red: 0.3, green: 0.9, blue: 0.8)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.cyan.opacity(0.1))
                        )
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            waveformAnimation = true
        }
    }
    
    private func waveformHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 20
        let maxHeight: CGFloat = 80
        let center = 15.0
        let distance = abs(Double(index) - center)
        let multiplier = 1.0 - (distance / 15.0)
        
        return waveformAnimation 
            ? baseHeight + (maxHeight - baseHeight) * multiplier
            : baseHeight + (maxHeight - baseHeight) * multiplier * 0.3
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(showWelcome: .constant(true))
    }
}
