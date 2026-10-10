# Xcode Setup Checklist for PlayGTA5 iPad Wrapper

Use this checklist to ensure your Xcode project is configured correctly for iPad Pro M1.

## ✅ Project Creation

- [ ] Create new iOS App project in Xcode
- [ ] Product Name: `PlayGTA5Wrapper`
- [ ] Team: Select your Apple Developer Team
- [ ] Organization ID: `com.playgta5` (or your domain)
- [ ] Bundle Identifier: `com.playgta5.wrapper`
- [ ] Interface: SwiftUI
- [ ] Lifecycle: SwiftUI App
- [ ] Storage: None
- [ ] Include Tests: No

## ✅ Add Swift Files to Project

- [ ] Drag `PlayGTA5WrapperApp.swift` into Xcode
  - [ ] Check "Copy items if needed"
  - [ ] Add to target: PlayGTA5Wrapper
- [ ] Drag `ContentView.swift`
- [ ] Drag `GameWebView.swift`
- [ ] Drag `GameDataManager.swift`
- [ ] Drag `TouchControlsView.swift`
- [ ] Verify all files appear in Build Phases → Compile Sources

## ✅ Build Settings

### Architecture
- [ ] Select project → Targets → PlayGTA5Wrapper
- [ ] Build Settings tab
- [ ] Search "Architectures"
- [ ] Set to: `arm64`
- [ ] Valid Architectures: `arm64`
- [ ] Supported Platforms: ipados

### Deployment
- [ ] Search "iOS Deployment Target"
- [ ] Set to: `17.0` or later
- [ ] Minimum Deployment Target: `17.0`

### Optimization
- [ ] Search "Optimization Level"
- [ ] Set to: `Optimize for Size [-Os]`
- [ ] Search "Strip Debug Symbols"
- [ ] Set to: `Yes`

### Capabilities
- [ ] Capability: Metal Support (should be automatic)
- [ ] Search "Metal"
- [ ] Ensure not disabled

## ✅ Info.plist Configuration

- [ ] Project → Info.plist
- [ ] Add/Verify these keys:
  - [ ] `CFBundleDisplayName`: "PlayGTA5"
  - [ ] `CFBundleIdentifier`: "com.playgta5.wrapper"
  - [ ] `MinimumOSVersion`: "17.0"
  - [ ] `UIDeviceFamily`: iPad (2)
  - [ ] `UIRequiredDeviceCapabilities`: arm64, metal
  - [ ] `UISupportedInterfaceOrientations~ipad`: LandscapeLeft, LandscapeRight
  - [ ] `NSLocalNetworkUsageDescription`: "PlayGTA5 needs local file access"

## ✅ App Icons

- [ ] Xcode → Assets.xcassets
- [ ] Click AppIcon
- [ ] If you have GTA V logo PNG:
  - [ ] Drag icon into "iPad Pro 12.9 (2x)" slot (167x167 px)
  - [ ] Drag icon into "iPad Pro 12.9 (3x)" slot (267x267 px)
  - [ ] Drag icon into other iPad slots
- [ ] If no icon:
  - [ ] Keep default for now
  - [ ] Can replace later

## ✅ Launch Screen

- [ ] Xcode → Select LaunchScreen.storyboard
- [ ] Set background to black
- [ ] Add app name label (optional)
- [ ] Keep simple — it only shows for a moment

## ✅ Device Selection

- [ ] Top-left in Xcode: Select target device
- [ ] Choose "iPad Pro (12.9-inch) (7th generation)" (M1)
- [ ] Or select physical iPad if connected
- [ ] Verify it says "arm64" in device info

## ✅ Code Signing

- [ ] Project → PlayGTA5Wrapper target
- [ ] Signing & Capabilities tab
- [ ] Team: Select your Apple Developer Team
- [ ] Provisioning Profile: Automatic or select manually
- [ ] Development Team: Must match bundle ID

## ✅ Build and Run

- [ ] Cmd + B (Build)
  - [ ] Resolve any compilation errors
  - [ ] Check Console for warnings
- [ ] Cmd + R (Run)
  - [ ] App launches on iPad
  - [ ] Check Console (Cmd + Shift + Y) for errors
  - [ ] If crashes, review crash log

## ✅ Game Files Setup

- [ ] On iPad, open Files app
- [ ] Navigate to "On My iPad" → "PlayGTA5Wrapper"
- [ ] Create folder: "PlayGTA5"
- [ ] Copy extracted game files into it
- [ ] Folder structure should be:
  ```
  Documents/PlayGTA5/
  ├─ homepage.html  (or index.html)
  ├─ game.js
  ├─ .mirror/       (extracted assets folder)
  └─ ...
  ```
- [ ] Relaunch the app
- [ ] App should detect game files automatically

## ✅ Test on Simulator

- [ ] Select "iPad Pro (12.9-inch) (7th generation)"
- [ ] Cmd + R
- [ ] Simulator should launch
- [ ] App should show status message
- [ ] If no game files:
  - [ ] Should show "No game files found" message
  - [ ] This is expected on simulator

## ✅ Test on Physical iPad

- [ ] Connect iPad Pro M1 via USB
- [ ] Unlock iPad and trust this computer
- [ ] Xcode → Window → Devices and Simulators
- [ ] Verify iPad appears and is trusted
- [ ] Select iPad as run destination
- [ ] Cmd + R
- [ ] App installs and launches on iPad
- [ ] Check Console for errors

## ✅ Archive and Export

- [ ] Product → Archive
- [ ] Select your Team for signing
- [ ] Choose "Distribute App"
- [ ] Select distribution method:
  - [ ] "Ad Hoc" (for testing on specific devices)
  - [ ] "Development" (same as Ad Hoc)
  - [ ] "App Store Connect" (for app store)
- [ ] Select signing options and provisioning profile
- [ ] Choose export location
- [ ] .ipa file is created

## ✅ Troubleshooting

### Build Fails
- [ ] Clean build folder (Cmd + Shift + K)
- [ ] Check console for error messages
- [ ] Verify all Swift files are in "Compile Sources"
- [ ] Ensure deployment target is 17.0+

### App Crashes on Launch
- [ ] Check Console (Cmd + Shift + Y)
- [ ] Look for "Thread 1: signal SIGABRT" or "Fatal error"
- [ ] Check Info.plist for missing keys
- [ ] Verify team/signing is set

### Game Files Not Found
- [ ] Check Files app path: Documents/PlayGTA5/
- [ ] Verify homepage.html or game.js exists
- [ ] Restart the app
- [ ] Check console for GameDataManager messages

### Touch Controls Don't Work
- [ ] Tap the control overlay to ensure it has focus
- [ ] Check that web view is loaded (not blank)
- [ ] Verify game JavaScript is listening for input
- [ ] Test in Xcode Console

### WebView Shows Blank Screen
- [ ] Check console for WebKit errors
- [ ] Verify game files are valid and complete
- [ ] Try refreshing (pull-to-refresh if supported)
- [ ] Check memory usage (may have crashed silently)

## ✅ Performance Optimization

- [ ] Profile with Instruments (Xcode → Product → Profile)
- [ ] Check memory usage (should stay under 4GB)
- [ ] Monitor CPU (should stay under 80%)
- [ ] Check frame rate in game (60 FPS ideal, 30 FPS minimum)
- [ ] If performance is poor:
  - [ ] Reduce game asset quality
  - [ ] Close other apps on iPad
  - [ ] Increase device memory to 8GB+

## ✅ Final Checks Before .ipa Export

- [ ] App builds without errors
- [ ] App runs on iPad Pro M1 without crashing
- [ ] Game files are detected and loaded
- [ ] Touch controls respond
- [ ] At least 30 FPS in gameplay
- [ ] Memory usage stable (no leaks)
- [ ] No console errors during gameplay
- [ ] Orientation lock is landscape only

---

**Note:** This is a vibecoded project with known bugs. Expect instability and crashes during development. See `VIBECODE_DISCLAIMER.md` for details.
