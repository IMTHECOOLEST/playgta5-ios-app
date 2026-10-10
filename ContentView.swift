import Foundation
import SwiftUI

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

        // Standard iOS Documents paths
        candidates.append(documentsURL.appendingPathComponent("PlayGTA5"))
        searchLog.append("📁 Documents/PlayGTA5")
        
        candidates.append(documentsURL.appendingPathComponent("PlayGTA5/.mirror"))
        searchLog.append("📁 Documents/PlayGTA5/.mirror")
        
        candidates.append(documentsURL.appendingPathComponent("PlayGTA5/game"))
        searchLog.append("📁 Documents/PlayGTA5/game")
        
        candidates.append(documentsURL.appendingPathComponent("PlayGTA5/root"))
        searchLog.append("📁 Documents/PlayGTA5/root")

        // Application Support paths (LiveContainer compatible)
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            candidates.append(appSupportURL.appendingPathComponent("PlayGTA5"))
            searchLog.append("📁 Application Support/PlayGTA5")
            
            candidates.append(appSupportURL.appendingPathComponent("PlayGTA5/.mirror"))
            searchLog.append("📁 Application Support/PlayGTA5/.mirror")
        }

        // Library paths (for extracted games)
        if let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
            candidates.append(libraryURL.appendingPathComponent("PlayGTA5"))
            searchLog.append("📁 Library/PlayGTA5")
        }

        // Caches directory (sometimes used in LiveContainer)
        if let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            candidates.append(cachesURL.appendingPathComponent("PlayGTA5"))
            searchLog.append("📁 Caches/PlayGTA5")
        }

        // Temp directory
        candidates.append(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PlayGTA5"))
        searchLog.append("📁 Temp/PlayGTA5")

        self.searchPaths = searchLog
        
        print("[GameDataManager] Scanning \(candidates.count) locations...")
        for path in searchLog {
            print("[GameDataManager] Checking: \(path)")
        }

        for candidate in candidates {
            if checkCandidate(candidate) {
                return
            }
        }

        didFindGame = false
        statusMessage = """
        ❌ No game files found in standard locations.
        Tap 'Browse' to manually select your PlayGTA5 folder.
        Or copy files to Documents/PlayGTA5/ and relaunch.
        """
        print("[GameDataManager] ❌ Game not found in any location")
    }

    private func checkCandidate(_ candidate: URL) -> Bool {
        print("[GameDataManager] Probing: \(candidate.path)")

        // Check for homepage.html
        let homepageURL = candidate.appendingPathComponent("homepage.html")
        if fileExists(at: homepageURL) {
            print("[GameDataManager] ✅ Found homepage.html")
            detectedGameURL = candidate
            didFindGame = true
            statusMessage = "✅ Game found! Tap 'Load Game' to start."
            return true
        }

        // Check for index.html
        let indexURL = candidate.appendingPathComponent("index.html")
        if fileExists(at: indexURL) {
            print("[GameDataManager] ✅ Found index.html")
            detectedGameURL = candidate
            didFindGame = true
            statusMessage = "✅ Game found! Tap 'Load Game' to start."
            return true
        }

        // Check for game.js
        let gameJSURL = candidate.appendingPathComponent("game.js")
        if fileExists(at: gameJSURL) {
            print("[GameDataManager] ✅ Found game.js")
            detectedGameURL = candidate
            didFindGame = true
            statusMessage = "✅ Game root found! Tap 'Load Game' to start."
            return true
        }

        // Check for .mirror subfolder with files
        let mirrorURL = candidate.appendingPathComponent(".mirror")
        if fileExists(at: mirrorURL) {
            if fileExists(at: mirrorURL.appendingPathComponent("homepage.html")) || 
               fileExists(at: mirrorURL.appendingPathComponent("index.html")) {
                print("[GameDataManager] ✅ Found .mirror with entry file")
                detectedGameURL = mirrorURL
                didFindGame = true
                statusMessage = "✅ Game data folder found! Tap 'Load Game' to start."
                return true
            }
        }

        // List directory contents for debugging
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: candidate.path)
            if !contents.isEmpty {
                print("[GameDataManager] Contents: \(contents.prefix(10))")
            }
        } catch {
            print("[GameDataManager] Directory not accessible: \(error)")
        }

        return false
    }

    func setGameURL(_ url: URL) {
        if checkCandidate(url) {
            return
        }
        
        // If direct path doesn't work, try treating it as the root
        detectedGameURL = url
        didFindGame = true
        statusMessage = "✅ Manual folder selected. Tap 'Load Game'."
        print("[GameDataManager] User selected: \(url.path)")
    }

    func ensureDirectoryExists(at url: URL) {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            print("[GameDataManager] Created directory: \(url.path)")
        } catch {
            print("[GameDataManager] Failed to create directory: \(error)")
        }
    }

    func copyIfNeeded(from source: URL, to destination: URL) {
        if fileManager.fileExists(atPath: destination.path) {
            print("[GameDataManager] Destination already exists, skipping copy")
            return
        }

        do {
            try fileManager.copyItem(at: source, to: destination)
            print("[GameDataManager] Copied \(source.path) to \(destination.path)")
        } catch {
            print("[GameDataManager] Copy failed: \(error)")
        }
    }

    private func fileExists(at url: URL) -> Bool {
        let exists = fileManager.fileExists(atPath: url.path)
        if exists {
            print("[GameDataManager] ✓ Found: \(url.lastPathComponent)")
        }
        return exists
    }
}
