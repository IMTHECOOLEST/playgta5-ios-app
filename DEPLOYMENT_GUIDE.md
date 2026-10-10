# Deploy PlayGTA5 iOS Wrapper to iPad — Complete Guide

## Overview

This guide walks you through packaging the PlayGTA5 wrapper as a signed `.ipa` file ready for installation on iPad Pro M1.

## Prerequisites

- Xcode 15.0+ with iOS 17.0+ SDK
- Apple Developer Account (free or paid)
- iPad Pro M1 with iOS 17.0+
- Valid provisioning profile for your iPad
- Game files extracted to `Documents/PlayGTA5/` on the iPad

## Step 1: Verify Your Code Signing Setup

### Option A: Automatic Signing (Recommended)

1. In Xcode: Project → PlayGTA5Wrapper → Signing & Capabilities
2. Check "Automatically manage signing"
3. Team: Select your Apple Developer Team
4. Bundle Identifier: Verify it matches `com.playgta5.wrapper`
5. Xcode will create/fetch provisioning profiles automatically

### Option B: Manual Signing

1. Go to [developer.apple.com/account](https://developer.apple.com/account)
2. Create or select a **Development Certificate**
3. Register your iPad's UDID:
   - Connect iPad to Mac
   - Xcode → Window → Devices and Simulators
   - Click your iPad → Copy UDID
   - developer.apple.com → Devices → Add UDID
4. Create a **Provisioning Profile** for your bundle ID
5. Download and drag the `.mobileprovision` file into Xcode
6. In Xcode: Project → PlayGTA5Wrapper → Signing & Capabilities
7. Select the provisioning profile from the dropdown

## Step 2: Configure Release Build Settings

1. **Select Scheme:** Top-left in Xcode, click "PlayGTA5Wrapper" → "Edit Scheme"
2. **Archive Configuration:** Set to "Release"
3. **Build Settings:**
   - Search "Optimization Level" → Set to `Optimize for Size [-Os]`
   - Search "Strip Debug Symbols" → Set to `Yes`
   - Search "Dead Code Stripping" → Set to `Yes`
   - This keeps the .ipa size small

## Step 3: Build and Archive

1. **Clean build:**
   ```
   Cmd + Shift + K
   ```

2. **Build for the iPad:**
   ```
   Cmd + B
   ```
   - Resolve any compile errors
   - Check Console for warnings

3. **Archive the app:**
   ```
   Product → Archive
   ```
   - Select your target (PlayGTA5Wrapper)
   - Xcode builds and archives
   - Opens the Organizer window
   - Your archive appears in the list

## Step 4: Export as .ipa

### For Ad Hoc Distribution (Recommended for Testing)

1. In Organizer, select your archive
2. Click "Distribute App"
3. Choose "Ad Hoc"
4. Click "Next"
5. **App Signing Options:**
   - Select your Team
   - Provisioning Profile: Select the one you created
   - Click "Next"
6. **Export Options:**
   - "Rebuild from Bitcode": Uncheck (not needed)
   - "Strip Swift Symbols": Uncheck (keep for debugging)
   - Click "Next"
7. **Choose Export Destination:**
   - Select a folder to save the .ipa
   - Name: `PlayGTA5Wrapper.ipa`
   - Click "Export"
8. ✅ `.ipa` file is created

### For App Store Distribution

1. In Organizer, select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Follow prompts to upload to App Store
   - Requires App Store app created in App Store Connect
   - Requires review by Apple (takes 24-48 hours)
   - **Note:** This project is vibecoded and won't pass review as-is

## Step 5: Install .ipa on iPad

### Option A: Xcode (Easiest)

1. Connect iPad to Mac via USB
2. Open Xcode → Window → Devices and Simulators
3. Click your iPad
4. Click the "+" button under "Installed Apps"
5. Select the `.ipa` file
6. Click "Install"
7. App appears on iPad after a few seconds

### Option B: Apple Configurator 2 (Mac Only)

1. Download Apple Configurator 2 from App Store
2. Connect iPad
3. Drag the `.ipa` file onto the iPad name in Configurator
4. Tap "Install" on iPad
5. App installs

### Option C: Finder (macOS 11+)

1. Connect iPad to Mac
2. Open Finder
3. Click iPad in sidebar
4. Click "Apps" tab
5. Drag `.ipa` into the "Installed Apps" section
6. Wait for install to complete

### Option D: TestFlight (If Using App Store Connect)

1. Upload .ipa to App Store Connect
2. Add testers in TestFlight section
3. Testers install via TestFlight app
4. Requires App Store app account

## Step 6: Launch and Test on iPad

1. Find "PlayGTA5" app on the home screen
2. Tap to launch
3. App should start and search for game files
4. **If "Game found" message appears:**
   - Game files are detected ✅
   - Tap "Load Game"
   - Game should appear in the WebView
5. **If "No game files found" appears:**
   - Copy game files to `Documents/PlayGTA5/`
   - Close app completely
   - Relaunch
   - Should now detect files

## Step 7: Verify Game Installation

### Check Game Files on iPad

1. Open Files app on iPad
2. Navigate to "On My iPad" → "PlayGTA5Wrapper"
3. Verify these files/folders exist:
   - `PlayGTA5/` folder
   - Inside: `homepage.html` (or `index.html`)
   - Inside: `.mirror/` folder with game assets
   - Inside: `game.js` and other game scripts

### Test Gameplay

1. Tap the game area
2. Wait for the loading screen to appear
3. Once loaded:
   - Try movement with the D-pad
   - Try action buttons
   - Game should respond to touch input
4. **If game doesn't load:**
   - Check Console in Xcode (if still connected)
   - Review `VIBECODE_DISCLAIMER.md`
   - Try closing app and reopening

## Troubleshooting Deployment

### "App installation failed"
- Verify the `.ipa` file is valid
- Ensure iPad is fully updated to iOS 17.0+
- Remove old version of app first
- Try again with Configurator 2

### "Signing error: No valid provisioning profile"
- Check developer.apple.com that certificate is valid
- Verify provisioning profile includes your iPad's UDID
- Regenerate provisioning profile if needed
- In Xcode: Reset Xcode signing preferences (Xcode → Preferences → Accounts → Right-click team → Reset)

### "Game files not found after install"
- Use Files app to verify folder structure
- Ensure folder is `PlayGTA5/` (exact case)
- Restart app
- Try copying files again using Configurator 2

### "App crashes immediately"
- Check if game files are corrupted
- Verify iOS version is 17.0+
- Free up iPad memory (close other apps)
- Reinstall app
- See `VIBECODE_DISCLAIMER.md` for known issues

### "WebView shows blank screen"
- Game files may be incomplete
- Memory pressure may have killed the WebView
- Game may be crashing silently
- Try restarting iPad
- Reinstall app and game files

## Performance Tuning

If the game runs slowly on iPad:

1. **Reduce game asset quality:**
   - Replace textures with lower-resolution versions
   - Reduce shader complexity

2. **Lower WebView memory footprint:**
   - Edit `GameWebView.swift`:
     ```swift
     config.preferences.javaScriptEnabled = true
     config.preferences.minimumFontSize = 0
     ```

3. **Profile with Instruments:**
   - Xcode → Product → Profile
   - Monitor Memory, CPU, GPU
   - Look for memory leaks (Allocations instrument)

## Creating a Release Build Script

To automate archive + export:

```bash
#!/bin/bash

# Build and archive
xcodebuild archive \
  -project PlayGTA5Wrapper.xcodeproj \
  -scheme PlayGTA5Wrapper \
  -configuration Release \
  -archivePath ./build/PlayGTA5Wrapper.xcarchive

# Export as .ipa
xcodebuild -exportArchive \
  -archivePath ./build/PlayGTA5Wrapper.xcarchive \
  -exportOptionsPlist ./ExportOptions.plist \
  -exportPath ./build/

echo "✅ .ipa created at ./build/PlayGTA5Wrapper.ipa"
```

Save as `build.sh` and run:
```bash
chmod +x build.sh
./build.sh
```

## Final Checklist

- [ ] `.ipa` file is generated
- [ ] App installs on iPad Pro M1
- [ ] Game files are accessible
- [ ] App launches without crashing
- [ ] Touch controls respond
- [ ] Game loads in WebView
- [ ] Performance is acceptable (30+ FPS)
- [ ] No crash logs in Xcode Console

---

**Next Steps:**

- If you want to distribute to App Store, see the approval checklist (separate document)
- For bug fixes, consult `VIBECODE_DISCLAIMER.md`
- For advanced optimization, profile with Instruments

✅ **You now have a working PlayGTA5 iPad wrapper .ipa ready for deployment.**
