import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {
    let gameRootURL: URL
    @Binding var controlState: GameControlState

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

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

        let script = "window.__internalGameControls = { moveX: \(moveX), moveY: \(moveY), actionA: \(actionA), actionB: \(actionB), sprint: \(sprint), jump: \(jump) };"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func loadGame(in webView: WKWebView) {
        let candidateFiles = [
            gameRootURL.appendingPathComponent("homepage.html"),
            gameRootURL.appendingPathComponent("index.html"),
            gameRootURL.appendingPathComponent(".mirror").appendingPathComponent("homepage.html"),
            gameRootURL.appendingPathComponent(".mirror").appendingPathComponent("index.html")
        ]

        for candidate in candidateFiles {
            if FileManager.default.fileExists(atPath: candidate.path) {
                let request = URLRequest(url: candidate)
                webView.load(request)
                return
            }
        }

        let fallbackHTML = """
        <html><body style="background:#000;color:#fff;font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;">
        <div style="text-align:center;">
        <h2>PlayGTA5</h2>
        <p>No game entry file was found in the selected game folder.</p>
        <p>Place the extracted game files inside Documents/PlayGTA5/ and relaunch.</p>
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
    }
}
