# Build Instructions for PlayGTA5 iPad Wrapper

## Prerequisites

- **Xcode 15.0+** (arm64 iOS development)
- **iOS 17.0+** deployment target
- **Apple Developer Account** (for signing and .ipa export)
- **iPad Pro M1** or simulator with 8GB+ RAM
- Game files extracted to `Documents/PlayGTA5/`

## Step 1: Setup in Xcode

1. **Clone or open this repo**
   ```bash
   git clone https://github.com/IMTHECOOLEST/playgta5-ios-app.git
   cd playgta5-ios-app
   ```

2. **Create an Xcode project**
   - File → New → Project
   - Choose "App"
   - Product Name: `PlayGTA5Wrapper`
   - Team: Your Apple Developer Team
   - Organization Identifier: `com.playgta5` (or your domain)
   - Interface: SwiftUI
   - Storage: None

3. **Copy the Swift files into your Xcode project**
   - Drag these into Xcode:
     - `PlayGTA5WrapperApp.swift`
     - `ContentView.swift`
     - `GameWebView.swift`
     - `GameDataManager.swift`
     - `TouchControlsView.swift`
   - Ensure "Copy items if needed" is checked
   - Add to target: `PlayGTA5Wrapper`

4. **Configure app icons**
   - In Xcode: Select project → Targets → PlayGTA5Wrapper
   - Go to General → App Icons and Launch Screen
   - If you have a GTA V logo PNG, drag it here and select all sizes
   - If not, keep the default

## Step 2: Configure Build Settings

1. **Select the project root** in Xcode
2. **Select the target** (PlayGTA5Wrapper)
3. **Go to Build Settings tab**
4. **Configure for arm64 only:**
   - Search for "Architectures"
   - Set to `arm64` (remove arm64e if present)
   - Set to `arm64` for "Valid Architectures"

5. **Memory optimization (for 8GB iPad):**
   - Search for "Optimization Level"
   - Set to `Optimize for Size [-Os]`
   - Search for "Strip Debug Symbols"
   - Set to `Yes` (helps reduce memory footprint)

6. **Deployment target:**
   - Search for "iOS Deployment Target"
   - Set to `17.0`

7. **Enable Metal:**
   - Search for "Metal"
   - Ensure Metal is supported (should be automatic on iPad Pro)

## Step 3: Configure Info.plist

1. **In Xcode**, select the project
2. **Info.plist** → Right-click → Open As → Source Code
3. **Add these keys** (if not present):
   ```xml
   <key>UIRequiredDeviceCapabilities</key>
   <array>
       <string>arm64</string>
       <string>metal</string>
   </array>
   <key>UISupportedInterfaceOrientations~ipad</key>
   <array>
       <string>UIInterfaceOrientationLandscapeRight</string>
       <string>UIInterfaceOrientationLandscapeLeft</string>
   </array>
   <key>NSLocalNetworkUsageDescription</key>
   <string>PlayGTA5 needs to access local game files</string>
   ```

## Step 4: Set up the Game Files Folder

1. **On the iPad** (or simulator):
   - Open Files app
   - Navigate to `On My iPad` → `PlayGTA5Wrapper`
   - Create a folder: `PlayGTA5`

2. **Copy your extracted game files:**
   - The wrapper looks for:
     - `Documents/PlayGTA5/homepage.html` (or `index.html`)
     - `Documents/PlayGTA5/.mirror/` (extracted assets folder)
     - `Documents/PlayGTA5/game.js`
   - Drag files into the Files app

3. **Relaunch the app** — it will detect the files automatically

## Step 5: Build and Test

1. **Select the iPad as the run destination**
   - Top-left in Xcode: Select "PlayGTA5Wrapper" → Choose iPad Pro M1

2. **Build and run:**
   ```
   Cmd + R
   ```

3. **Watch the console** (Cmd + Shift + Y) for errors

4. **If the game loads:**
   - Tap the screen to start
   - Use the on-screen controls (D-pad + buttons)
   - Check the vibecode disclaimer if things break

## Step 6: Archive and Export to .ipa

### For Ad Hoc / Development Distribution:

1. **Product → Archive**
2. **Select your Team** (signing)
3. **"Distribute App"** → Choose "Ad Hoc"
4. **Select signing options** and provisioning profile
5. **Export** → Save as `.ipa`

### For App Store:

1. **Ensure bundle ID matches** your App Store app
2. **Product → Archive**
3. **"Distribute App"** → Choose "App Store Connect"
4. **Follow prompts** to upload

## Troubleshooting

### "Game files not found"
- Ensure the `PlayGTA5` folder is in `Documents` on the iPad
- Restart the app
- Check that `homepage.html` or `game.js` exists in the folder

### "WebView crashes immediately"
- Check console for memory errors
- Reduce game assets or deploy with optimized shaders
- Ensure iOS 17.0+ and at least 8GB RAM available

### "Touch controls not working"
- Tap the control overlay to activate it
- Check that the web view has focus (console shows input)
- Verify the game's input handler can see the synthetic events

### "App crashes on launch"
- Check Xcode Console (Cmd + Shift + Y)
- Review the vibecode disclaimer
- Try building/running again

## Notes

- **This is vibecoded and unstable** — expect crashes
- The app is optimized for arm64/iPad Pro M1 (8GB RAM)
- Metal rendering should be enabled automatically via WKWebView
- Touch controls are a **proof of concept** — map carefully to the game's input handler
- For production, implement proper error handling, logging, and memory management
