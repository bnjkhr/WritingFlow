import SwiftUI
import SwiftData

@main
struct WritingFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(DataStoreManager.shared.container)
    }
}