# PlayGTA5 iOS Wrapper

A lightweight native iOS shell for running PlayGTA5 in a `WKWebView` on iPad hardware. This project does not port the game engine to Metal; instead, it wraps the browser-based game in a custom app container with a touch overlay, local game-data detection, and app-level launch logic for iPad Pro M1-era devices.

## Overview

This repository contains:

- a SwiftUI iOS app entry point
- automatic detection of local game folders
- `WKWebView` loading of `homepage.html`, `index.html`, or other local game entry files
- in-app touch controls and controller support
- extra guidance for build, deployment, and troubleshooting

The wrapper is designed for running a locally stored PlayGTA5 game bundle from a folder such as `Documents/PlayGTA5/` or `Documents/PlayGTA5/.mirror/`.

## What this project includes

- `WKWebView` wrapper for local HTML/JS game assets
- automatic scan for common PlayGTA5 folder locations
- manual folder selection via file picker
- custom touch controls for movement and actions
- controller polling via GameController on connected gamepads
- app structure optimized for iPad Pro M1 / arm64 flow
- project docs for build, deployment, and Xcode setup

## Supported game folder layouts

The app checks for game content in these common paths:

- `Documents/PlayGTA5/`
- `Documents/PlayGTA5/.mirror/`
- `Documents/PlayGTA5/game/`
- `Documents/PlayGTA5/root/`
- `Application Support/PlayGTA5/`
- `Library/PlayGTA5/`
- `Caches/PlayGTA5/`
- `Temporary/PlayGTA5/`

Typical entry files include:

- `homepage.html`
- `index.html`
- `game.js`
- files inside a `.mirror` extracted asset folder

## Repository structure

- `PlayGTA5WrapperApp.swift` — app entry point
- `ContentView.swift` — app UI, status screen, game detection, and file picker
- `GameWebView.swift` — loads the detected game page inside `WKWebView`
- `TouchControlsView.swift` — touch controls and optional controller mapping
- `GameDataManager.swift` — search and detection logic for game folders
- `Package.swift` — Swift package manifest for the project
- `Info.plist` — app configuration and required capabilities
- `BUILD_INSTRUCTIONS.md` — build and setup guide
- `DEPLOYMENT_GUIDE.md` — export and deployment notes
- `PROJECT_STRUCTURE.md` — architectural overview
- `XCODE_SETUP_CHECKLIST.md` — Xcode setup checklist
- `VIBECODE_DISCLAIMER.md` — project caveat/usage reminder

## Requirements

- Xcode 15+ recommended
- iOS 17.0+ deployment target
- Apple Developer account for signing and export
- iPad Pro M1 or equivalent arm64 device
- extracted local game files stored on-device

## Build and run

1. Open the project in Xcode.
2. Ensure the target is set for arm64/iPad deployment.
3. Add the Swift files to your app target if you are building a fresh Xcode project.
4. Configure signing with your Apple Developer team.
5. Copy the PlayGTA5 game files into one of the supported folder locations.
6. Launch the app and let it discover the game automatically.

## Game data setup

Place the game bundle in a folder like:

- `/Documents/PlayGTA5/`
- `/Documents/PlayGTA5/.mirror/`
- `/Library/Application Support/PlayGTA5/`

When the app finds a valid entry file, it loads the page inside the wrapper and syncs touch/controller states into `window.__internalGameControls`.

## Controls

The wrapper includes:

- left analog stick / D-pad style movement
- action buttons A/B
- sprint and jump buttons
- optional GameController polling when a controller is connected

## Current project status

This repository is best understood as a proof-of-concept wrapper and app shell rather than a full native game engine port. The browser game remains the primary runtime, while the iOS app handles local asset loading, input overlay, and app packaging.

## Known limitations

- not a native Metal port of GTA V
- highly dependent on the browser game asset structure
- touch/controller input is best-effort and may require tuning
- memory and performance depend on the target iPad and asset size
- user must provide and legalize their own game files

## Important note

This project is meant for running local game files on a device you control. You still need the actual game content and an appropriate Apple signing setup for installation. The app shell does not include or redistribute the game itself.

## Documentation

For deeper setup and deployment details, see:

- `BUILD_INSTRUCTIONS.md`
- `DEPLOYMENT_GUIDE.md`
- `PROJECT_STRUCTURE.md`
- `XCODE_SETUP_CHECKLIST.md`
- `VIBECODE_DISCLAIMER.md`

## License and usage

This repository is provided as-is for experimentation, local development, and wrapper-style deployment. Use it responsibly and only with assets you are authorized to run and distribute.
