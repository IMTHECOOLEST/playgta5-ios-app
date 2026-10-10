# PlayGTA5 iOS Wrapper

This repository contains a lightweight iOS app scaffold for wrapping the PlayGTA5 browser game in a native `WKWebView`, adding an on-screen input overlay and a dedicated game-data folder for iPad usage.

This is not a full native Metal port of the game engine. It is a realistic wrapper approach for iPad deployment that lets the existing browser game run in a native app shell while adding custom touch controls.

## What this scaffold includes

- `WKWebView` wrapper to load the game from local files
- Dedicated game data folder management for a `.mirror` or extracted game asset directory
- Custom touch control overlay for movement and actions
- Local file detection and startup checks
- iPad Pro M1 / arm64-focused app structure
- Documentation for archive/export to `.ipa`

## Project structure

- `PlayGTA5WrapperApp.swift` — app entry point
- `ContentView.swift` — main screen and app composition
- `GameDataManager.swift` — detects and organizes game files
- `GameWebView.swift` — loads the game in `WKWebView`
- `TouchControlsView.swift` — custom HUD controls for touch input
- `README.md` — build and signing instructions

## Recommended game directory layout

The app will try to locate the game files in these locations:

- `/Documents/PlayGTA5/`
- `/Documents/PlayGTA5/.mirror/`
- `/Library/Application Support/PlayGTA5/`

When the app finds a `homepage.html` or a game root folder, it loads it in the web view.

## Build in Xcode

1. Open Xcode
2. Create a new iOS app project
3. Set the product name to `PlayGTA5Wrapper`
4. Set the deployment target to `iOS 17.0+`
5. Add these Swift files to the app target
6. Select `SwiftUI` for interface
7. Set device orientation to iPad
8. Build for `arm64` only

## Sign and export to `.ipa`

1. Add your Apple Developer Team
2. Enable app signing in Xcode
3. Select a valid provisioning profile for iPad deployment
4. Archive the app
5. Export as `Ad Hoc` or `Development`
6. Save the `.ipa` archive

## Notes

- For app store or enterprise distribution, you still need a valid Apple Developer account and signing profile.
- The game engine itself remains a browser/WebGPU project; this app is only the iPad shell.
- If you want a true native Metal renderer, the game engine would need to be rewritten or ported away from browser-based rendering.

## Default folder behavior

The wrapper is intentionally simple and built for local game storage. For production, copy your extracted game data to one of the supported directories and relaunch the app.
