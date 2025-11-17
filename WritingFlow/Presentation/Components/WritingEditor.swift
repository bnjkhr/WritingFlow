import SwiftUI

struct WritingEditor: View {
    @Binding var text: String
    @Binding var isBackspaceBlocked: Bool
    let onTextChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isBackspaceBlocked {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Backspace is disabled - keep writing forward!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            
            TextEditor(text: $text)
                .font(.system(size: 18, design: .default))
                .lineSpacing(4)
                .padding()
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onChange(of: text) { _, newValue in
                    onTextChange(newValue)
                }
        }
    }
}

#Preview {
    @State var text: String = "Start writing here..."
    @State var isBlocked: Bool = true
    
    return VStack {
        WritingEditor(
            text: $text,
            isBackspaceBlocked: $isBlocked,
            onTextChange: { newText in
                print("Text changed: \(newText)")
            }
        )
        .padding()
    }
}