import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var gameDataManager: GameDataManager
    @State private var controlState = GameControlState()
    @State private var showFilePicker = false
    @State private var isLoading = false

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

    final class GameDataManager: ObservableObject {
        @Published var statusMessage: String = "Searching for game files..."
        @Published var detectedGameURL: URL?
        @Published var didFindGame: Bool = false
        @Published var searchPaths: [String] = []

        private let fileManager = FileManager.default
        private let documentsURL: URL

        init() {
            self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            self.detectedGameURL = nil
            self.statusMessage = "Searching for game files..."
            self.findGameFiles()
        }

        func findGameFiles() {
            var candidates: [URL] = []
            var searchLog: [String] = []

            candidates.append(documentsURL.appendingPathComponent("PlayGTA5"))
            searchLog.append("📁 Documents/PlayGTA5")

            candidates.append(documentsURL.appendingPathComponent("PlayGTA5/.mirror"))
            searchLog.append("📁 Documents/PlayGTA5/.mirror")

            candidates.append(documentsURL.appendingPathComponent("PlayGTA5/game"))
            searchLog.append("📁 Documents/PlayGTA5/game")

            candidates.append(documentsURL.appendingPathComponent("PlayGTA5/root"))
            searchLog.append("📁 Documents/PlayGTA5/root")

            if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                candidates.append(appSupportURL.appendingPathComponent("PlayGTA5"))
                searchLog.append("📁 Application Support/PlayGTA5")

                candidates.append(appSupportURL.appendingPathComponent("PlayGTA5/.mirror"))
                searchLog.append("📁 Application Support/PlayGTA5/.mirror")
            }

            if let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
                candidates.append(libraryURL.appendingPathComponent("PlayGTA5"))
                searchLog.append("📁 Library/PlayGTA5")
            }

            if let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                candidates.append(cachesURL.appendingPathComponent("PlayGTA5"))
                searchLog.append("📁 Caches/PlayGTA5")
            }

            candidates.append(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PlayGTA5"))
            searchLog.append("📁 Temp/PlayGTA5")

            self.searchPaths = searchLog

            for candidate in candidates {
                if checkCandidate(candidate) { return }
            }

            didFindGame = false
            statusMessage = """
            ❌ No game files found in standard locations.
            Tap 'Browse' to manually select your PlayGTA5 folder.
            Or copy files to Documents/PlayGTA5/ and relaunch.
            """
        }

        func checkCandidate(_ candidate: URL) -> Bool {
            let homepageURL = candidate.appendingPathComponent("homepage.html")
            if fileExists(at: homepageURL) {
                detectedGameURL = candidate
                didFindGame = true
                statusMessage = "✅ Game found! Tap 'Load Game' to start."
                return true
            }

            let indexURL = candidate.appendingPathComponent("index.html")
            if fileExists(at: indexURL) {
                detectedGameURL = candidate
                didFindGame = true
                statusMessage = "✅ Game found! Tap 'Load Game' to start."
                return true
            }

            let gameJSURL = candidate.appendingPathComponent("game.js")
            if fileExists(at: gameJSURL) {
                detectedGameURL = candidate
                didFindGame = true
                statusMessage = "✅ Game root found! Tap 'Load Game' to start."
                return true
            }

            let mirrorURL = candidate.appendingPathComponent(".mirror")
            if fileExists(at: mirrorURL) {
                if fileExists(at: mirrorURL.appendingPathComponent("homepage.html")) ||
                    fileExists(at: mirrorURL.appendingPathComponent("index.html")) {
                    detectedGameURL = mirrorURL
                    didFindGame = true
                    statusMessage = "✅ Game data folder found! Tap 'Load Game' to start."
                    return true
                }
            }

            return false
        }

        func setGameURL(_ url: URL) {
            if checkCandidate(url) { return }

            detectedGameURL = url
            didFindGame = true
            statusMessage = "✅ Manual folder selected. Tap 'Load Game'."
        }

        func fileExists(at url: URL) -> Bool {
            fileManager.fileExists(atPath: url.path)
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
