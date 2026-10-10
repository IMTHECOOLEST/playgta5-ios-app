import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {
    let gameRootURL: URL
    @Binding var controlState: GameControlState

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false

        DispatchQueue.main.async {
            loadGame(in: webView)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let moveX = controlState.moveX
        let moveY = controlState.moveY
        let actionA = controlState.actionA ? "true" : "false"
        let actionB = controlState.actionB ? "true" : "false"
        let sprint = controlState.sprint ? "true" : "false"
        let jump = controlState.jump ? "true" : "false"

        let script = """
        window.__internalGameControls = {
            moveX: \(moveX),
            moveY: \(moveY),
            actionA: \(actionA),
            actionB: \(actionB),
            sprint: \(sprint),
            jump: \(jump)
        };
        if (window.updateGameControls) window.updateGameControls();
        """

        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("[WebView] Script error: \(error)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func loadGame(in webView: WKWebView) {
        let candidateFiles = [
            gameRootURL.appendingPathComponent("homepage.html"),
            gameRootURL.appendingPathComponent("index.html"),
            gameRootURL.appendingPathComponent(".mirror/homepage.html"),
            gameRootURL.appendingPathComponent(".mirror/index.html"),
            gameRootURL.appendingPathComponent("game/homepage.html"),
            gameRootURL.appendingPathComponent("game/index.html")
        ]

        for candidate in candidateFiles {
            if FileManager.default.fileExists(atPath: candidate.path) {
                let request = URLRequest(url: candidate)
                webView.load(request)
                return
            }
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: gameRootURL.path)
            let htmlFiles = contents.filter { $0.hasSuffix(".html") }
            if let firstHTML = htmlFiles.first {
                let htmlURL = gameRootURL.appendingPathComponent(firstHTML)
                let request = URLRequest(url: htmlURL)
                webView.load(request)
                return
            }
        } catch {
            print("[WebView] Error listing directory: \(error)")
        }

        let fallbackHTML = """
        <html><body style="background:#000;color:#fff;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;">
        <div style="text-align:center;">
        <h2>PlayGTA5</h2>
        <p>❌ No game entry file found</p>
        <p>Expected: homepage.html, index.html, or .html file</p>
        <p>Path: \(gameRootURL.lastPathComponent)</p>
        </div>
        </body></html>
        """

        webView.loadHTMLString(fallbackHTML, baseURL: gameRootURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent: GameWebView

        init(_ parent: GameWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("[WebView] Navigation error: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("[WebView] Provisional navigation error: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("[WebView] ✅ Page loaded successfully")
        }
    }
}
