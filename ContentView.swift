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
        // ... existing candidate setup ...

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

    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
}
