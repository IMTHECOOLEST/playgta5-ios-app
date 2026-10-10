# ⚠️ VIBECODE DISCLAIMER

This iOS app wrapper is **vibecoded** and will have **major bugs**, crashes, and unpredictable behavior.

## Known Issues

- **WKWebView crashes** on memory pressure (common on iPad with large game assets)
- **Touch control mapping** may not sync correctly with the game input handler
- **Game data folder detection** can fail silently if the directory structure is different
- **Local file serving** may not work across all game asset types (shaders, textures, media)
- **Audio/WebAudio context** may not initialize properly on first launch
- **GPU memory management** is not optimized; Metal acceleration may be disabled
- **Orientation handling** can cause view corruption or crash
- **Control overlay** input events may not propagate correctly to the web view
- **No error recovery** — most failures result in a blank screen or immediate crash
- **No logging** — debugging requires Xcode console attachment

## What to expect

- The app will build and run on iPad Pro M1, but will be unstable
- Game assets may load partially or fail silently
- Touch controls may lag or not respond
- The app may crash during gameplay or asset loading
- Restarting the app multiple times may be required
- This is a **proof-of-concept**, not production-ready software

## Why?

This wrapper was generated rapidly without extensive testing. Real iOS game ports require:
- Proper memory management
- Robust error handling
- Extensive testing on actual hardware
- Proper async/await patterns
- Detailed logging and crash analytics
- Optimization for the target device

## If you want to fix it:

1. Review the crash logs in Xcode Console
2. Add proper error handling in `GameWebView.swift`
3. Implement memory warnings in `GameDataManager.swift`
4. Add proper WKWebView delegate callbacks
5. Test touch input mapping exhaustively
6. Profile GPU/Memory usage with Instruments

**You've been warned.** This is a learning/prototype project, not a shipping app.
