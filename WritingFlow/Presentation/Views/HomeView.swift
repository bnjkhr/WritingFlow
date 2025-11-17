import SwiftUI

struct HomeView: View {
    @State private var showingWritingSession = false
    
    var body: some View {
        VStack(spacing: 30) {
            // App Header
            VStack(spacing: 16) {
                Image(systemName: "pencil.and.outline")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 80))
                
                Text("WritingFlow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Focused writing with AI insights")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Main Action Button
            Button(action: {
                showingWritingSession = true
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Start Writing Session")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
            }
            .buttonStyle(.plain)
            
            // Features
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    FeatureCard(
                        icon: "timer",
                        title: "15-Minute Sessions",
                        description: "Focused writing with time limits"
                    )
                    
                    FeatureCard(
                        icon: "brain.head.profile",
                        title: "AI Insights",
                        description: "Get intelligent writing analysis"
                    )
                }
                
                HStack(spacing: 16) {
                    FeatureCard(
                        icon: "nosign",
                        title: "Backspace Block",
                        description: "Keep writing forward momentum"
                    )
                    
                    FeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress Tracking",
                        description: "Monitor your writing habits"
                    )
                }
            }
            
            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingWritingSession) {
            // WritingSessionView would go here
            Text("Writing Session View")
                .padding()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
        .frame(width: 800, height: 600)
}