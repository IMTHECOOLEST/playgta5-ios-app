import SwiftUI
import WebKit
import GameController

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
                    
                    // Show search paths in debug mode
                    if !gameDataManager.searchPaths.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Searched locations:")
                                .font(.caption)
                                .fontWeight(.bold)
                            ForEach(gameDataManager.searchPaths.prefix(5), id: \.self) { path in
                                Text(path)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: { gameDataManager.findGameFiles() }) {
                            Label("Scan Again", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { showFilePicker = true }) {
                            Label("Browse", systemImage: "folder")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .fileImporter(
                            isPresented: $showFilePicker,
                            allowedContentTypes: [.folder],
                            onCompletion: { result in
                                if case .success(let url) = result {
                                    gameDataManager.setGameURL(url)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
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
