import SwiftUI

struct ContentView: View {
    @State private var showingWritingSession = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "pencil.and.outline")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 60))
            
            Text("WritingFlow")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Focused writing with AI insights")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Start Writing Session") {
                showingWritingSession = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingWritingSession) {
            SimpleWritingSessionView()
        }
    }
}

#Preview {
    ContentView()
}