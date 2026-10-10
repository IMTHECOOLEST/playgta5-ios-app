# PlayGTA5 iOS Wrapper — Project Structure

## Files Overview

### App Entry Point
```
PlayGTA5WrapperApp.swift
├─ @main app entry
├─ Creates GameDataManager
├─ Sets dark theme
└─ Launches ContentView
```

### Main UI Container
```
ContentView.swift
├─ Detects game files or shows status
├─ Manages GameControlState
├─ Shows GameWebView if game found
├─ Shows touch controls overlay
└─ Shows fallback UI if no game
```

### Game Data Management
```
GameDataManager.swift
├─ Searches for game files in:
│  ├─ Documents/PlayGTA5/
│  ├─ Documents/PlayGTA5/.mirror/
│  ├─ Documents/PlayGTA5/game/
│  └─ Library/Application Support/PlayGTA5/
├─ Detects: homepage.html, game.js, .mirror folder
├─ Publishes status messages
└─ Creates directories if needed
```

### Web View Container
```
GameWebView.swift
├─ UIViewRepresentable wrapper for WKWebView
├─ WKWebViewConfiguration (allowsInlineMedia, Metal)
├─ Loads game from detected folder
├─ Syncs control state to JavaScript
├─ Has WKNavigationDelegate + WKUIDelegate
└─ Fallback HTML if no entry file found
```

### Touch Controls
```
TouchControlsView.swift
├─ AnalogStickView (movement input)
│  ├─ Circular drag with radius clamping
│  ├─ Returns normalized -1.0 to 1.0 values
│  └─ Resets on release
├─ Action Buttons (A, B, Sprint, Jump)
│  ├─ Toggle on/off visual feedback
│  ├─ Orange = pressed, Gray = idle
│  └─ Positioned bottom-right
└─ GameControlState struct
   ├─ moveX, moveY (analog stick)
   ├─ actionA, actionB (action buttons)
   ├─ sprint, jump (special controls)
   └─ Published to game via JavaScript
```

## Data Flow

```
PlayGTA5WrapperApp (main)
    ↓
    GameDataManager.findGameFiles()
    ├─ Searches Documents/PlayGTA5/
    └─ Sets detectedGameURL
    ↓
    ContentView
    ├─ Shows status if no game
    └─ If game found:
        ├─ GameWebView (loads homepage.html or index.html)
        │  ├─ WKWebView renders game
        │  ├─ Receives controlState updates
        │  └─ Syncs via JavaScript injection
        └─ TouchControlsView (overlay)
            └─ Emits controlState changes
```

## Control Input Flow

```
Touch Screen
    ↓
    AnalogStickView / ActionButton
    ├─ Gesture recognition
    └─ Updates @State controlState
    ↓
    GameWebView.updateUIView()
    ├─ Reads controlState
    ├─ Constructs JavaScript object
    └─ Calls evaluateJavaScript()
    ↓
    Game JavaScript
    ├─ Reads window.__internalGameControls
    ├─ Maps to game input handler
    └─ Updates player movement/actions
```

## Key Classes & Structs

### GameDataManager (ObservableObject)
- **Properties:**
  - `@Published statusMessage: String`
  - `@Published detectedGameURL: URL?`
  - `@Published didFindGame: Bool`
- **Methods:**
  - `findGameFiles()` — searches standard locations
  - `ensureDirectoryExists(at:)` — creates folders
  - `copyIfNeeded(from:to:)` — file copying

### GameControlState (struct)
- **Properties:**
  - `moveX: Double` (-1.0 to 1.0)
  - `moveY: Double` (-1.0 to 1.0)
  - `actionA: Bool` (button state)
  - `actionB: Bool`
  - `sprint: Bool`
  - `jump: Bool`

### GameWebView (UIViewRepresentable)
- **Config:**
  - WKWebViewConfiguration with inline media + Metal
  - Viewport: Full screen
  - Background: Black
- **Methods:**
  - `makeUIView()` — creates WKWebView
  - `updateUIView()` — syncs control state
  - `loadGame()` — loads HTML/JS files

### AnalogStickView (View)
- **Gesture:**
  - DragGesture with distance clamping
  - Clamps movement to circular boundary
- **Output:**
  - Normalized values on change
  - Resets to (0, 0) on release

## Configuration Files

### Info.plist
- Device Family: iPad (2)
- Min OS: 17.0
- Orientations: Landscape only
- Capabilities: arm64, Metal
- Permissions: Local network, Photos, Camera

### Build Settings
- Architecture: arm64
- Optimization: Size (-Os)
- Strip Debug: Yes
- Deployment: iOS 17.0

## Known Limitations

1. **No error handling** — crashes on missing files
2. **No logging** — debug via Xcode Console only
3. **Control sync is best-effort** — input may lag
4. **WKWebView memory** — may crash on large assets
5. **No restart logic** — must force-quit and relaunch
6. **Single-threaded** — all UI on main thread

## Future Improvements

- Add proper error boundaries and recovery
- Implement memory warnings and cleanup
- Add detailed logging/analytics
- Async file loading with progress
- Background game asset downloader
- Settings UI for control mapping
- Persistent game saves
- Crash recovery on relaunch
