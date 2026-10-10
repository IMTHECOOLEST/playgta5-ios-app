import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var gameDataManager: GameDataManager
    @State private var controlState = GameControlState()

    var body: some View {
        ZStack {
            if gameDataManager.didFindGame, let gameURL = gameDataManager.detectedGameURL {
                GameWebView(gameRootURL: gameURL, controlState: $controlState)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("PlayGTA5")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(gameDataManager.statusMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("Place the extracted game files in Documents/PlayGTA5/")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.white)
                .padding()
            }

            TouchControlsView(controlState: $controlState)
                .allowsHitTesting(true)
        }
    }
}

struct GameControlState {
    var moveX: Double = 0
    var moveY: Double = 0
    var actionA: Bool = false
    var actionB: Bool = false
    var sprint: Bool = false
    var jump: Bool = false
}
