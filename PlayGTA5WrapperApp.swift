import SwiftUI

@main
struct PlayGTA5WrapperApp: App {
    @StateObject private var gameDataManager = ContentView.GameDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gameDataManager: gameDataManager)
        }
    }
}
