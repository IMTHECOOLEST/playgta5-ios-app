import Foundation
import SwiftUI

final class GameDataManager: ObservableObject {
    @Published var statusMessage: String = "Searching for game files..."
    @Published var detectedGameURL: URL?
    @Published var didFindGame: Bool = false

    private let fileManager = FileManager.default
    private let documentsURL: URL

    init() {
        self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.detectedGameURL = nil
        self.statusMessage = "Searching for game files..."
        self.findGameFiles()
    }

    func findGameFiles() {
        let candidates = [
            documentsURL.appendingPathComponent("PlayGTA5"),
            documentsURL.appendingPathComponent("PlayGTA5/.mirror"),
            documentsURL.appendingPathComponent("PlayGTA5/game"),
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("PlayGTA5")
        ].compactMap { $0 }

        for candidate in candidates {
            if fileExists(at: candidate.appendingPathComponent("homepage.html")) {
                detectedGameURL = candidate
                didFindGame = true
                statusMessage = "Game found at: \(candidate.path)"
                return
            }

            if fileExists(at: candidate.appendingPathComponent(".mirror")) {
                detectedGameURL = candidate.appendingPathComponent(".mirror")
                didFindGame = true
                statusMessage = "Game data folder found at: \(candidate.path)"
                return
            }

            if fileExists(at: candidate.appendingPathComponent("game.js")) {
                detectedGameURL = candidate
                didFindGame = true
                statusMessage = "Game root found at: \(candidate.path)"
                return
            }
        }

        didFindGame = false
        statusMessage = "No game files found. Copy the PlayGTA5 folder to Documents/PlayGTA5 and relaunch."
    }

    func ensureDirectoryExists(at url: URL) {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            print("Failed to create directory: \(error)")
        }
    }

    func copyIfNeeded(from source: URL, to destination: URL) {
        if fileManager.fileExists(atPath: destination.path) {
            return
        }

        do {
            try fileManager.copyItem(at: source, to: destination)
        } catch {
            print("Copy failed: \(error)")
        }
    }

    private func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
}
