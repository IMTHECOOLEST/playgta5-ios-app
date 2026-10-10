import SwiftUI

@main
struct PlayGTA5WrapperApp: App {
    @StateObject private var gameDataManager = GameDataManager()

    var body: some Scene {
        WindowGroup {
            ContentView(gameDataManager: gameDataManager)
                .preferredColorScheme(.dark)
        }
    }
}
