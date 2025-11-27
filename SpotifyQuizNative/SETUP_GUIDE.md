# Complete Setup Guide - Native iOS Spotify Quiz App

## 🎯 What You're Building

A **native iOS app** (like Hitster) that uses the **official Spotify iOS SDK** for reliable music playback on mobile devices.

## ✅ Prerequisites

- Mac with **Xcode 14.0+** installed
- **CocoaPods** (`sudo gem install cocoapods`)
- **Spotify Premium account**
- Your Spotify App credentials (from developer dashboard)

---

## 📱 Step-by-Step Setup

### Step 1: Create Xcode Project

1. Open **Xcode**
2. **File → New → Project**
3. Select **iOS → App**
4. Configure:
   - Product Name: `SpotifyQuizNative`
   - Team: (Select your team)
   - Organization Identifier: `com.yourname.spotifyquiz`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Include Tests (optional)
5. **Save** in `/path/to/SpotifyQuizNative` folder

---

### Step 2: Install Spotify iOS SDK

1. **Open Terminal** and navigate to project:
   ```bash
   cd /path/to/SpotifyQuizNative
   ```

2. **Create Podfile** (already provided, but if needed):
   ```bash
   pod init
   ```

3. **Edit Podfile** - use the Podfile I created, or copy this:
   ```ruby
   platform :ios, '13.0'
   use_frameworks!

   target 'SpotifyQuizNative' do
     pod 'SpotifyiOS', '~> 1.2.2'
   end
   ```

4. **Install pods**:
   ```bash
   pod install
   ```

5. **‼️ IMPORTANT**: Close Xcode and open `SpotifyQuizNative.xcworkspace` (not .xcodeproj!)

---

### Step 3: Configure Spotify Developer Dashboard

1. Go to https://developer.spotify.com/dashboard
2. Select your existing app (or create new one)
3. Click **"Edit Settings"**
4. Add **Redirect URI**:
   ```
   spotifyquiznative://callback
   ```
5. **Save**
6. **Copy your Client ID** - you'll need it!

---

### Step 4: Configure iOS App

#### 4.1 Add URL Scheme

1. In Xcode, select **project** in navigator (blue icon)
2. Select **target** "SpotifyQuizNative"
3. Go to **"Info"** tab
4. Scroll to **"URL Types"**
5. Click **"+"** to add new URL Type:
   - **Identifier**: `com.spotify.sdk`
   - **URL Schemes**: `spotifyquiznative`
   - Role: Editor

#### 4.2 Update Info.plist

1. Right-click `Info.plist` → **"Open As" → "Source Code"**
2. Add this inside `<dict>` tag:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>spotify</string>
   </array>
   ```

#### 4.3 Add Client ID

1. Open `SpotifyManager.swift`
2. Find line: `private let clientID = "YOUR_SPOTIFY_CLIENT_ID"`
3. Replace with your actual Client ID:
   ```swift
   private let clientID = "abc123def456..." // Your actual ID
   ```

---

### Step 5: Add Swift Files to Xcode

1. In Xcode, **right-click** on "SpotifyQuizNative" folder in navigator
2. Select **"Add Files to SpotifyQuizNative..."**
3. Navigate to where you saved the Swift files
4. **Select ALL** these files:
   - `SpotifyManager.swift`
   - `APIManager.swift`
   - `SpotifyQuizNativeApp.swift`
   - `ContentView.swift`
   - `GameView.swift`
5. ✅ Check **"Copy items if needed"**
6. ✅ Check **"Create groups"**
7. Click **"Add"**

**Alternative**: Copy file contents and create files directly in Xcode:
- Right-click project → "New File" → Swift File
- Paste content from each file

---

### Step 6: Delete Default Files

Xcode creates some default files you don't need:

1. **Delete** (Move to Trash):
   - The default `ContentView.swift` (if it exists and you haven't replaced it)
   - The default `SpotifyQuizNativeApp.swift` (if it exists and you haven't replaced it)

Make sure you're using the versions I provided!

---

### Step 7: Build & Run

1. Select **iPhone simulator** or **your physical device** from dropdown
2. Click **"Build"** button (▶️) or press **Cmd+R**
3. Wait for build to complete...

**If you get build errors**, check:
- Did you open `.xcworkspace` (NOT `.xcodeproj`)?
- Is CocoaPods installed correctly?
- Did you add your Client ID?
- Are all Swift files added to the target?

---

### Step 8: Test the App

1. **Launch the app** on simulator/device
2. You should see **"Spotify Music Quiz"** screen
3. Click **"Login with Spotify"**
4. **Spotify app** should open (or web login if app not installed)
5. **Authorize** the app
6. You should be redirected back
7. Status should show **"Connected to Spotify"** (green dot)
8. Click **"Start Game"**
9. Click **"Start Round 1"**
10. **Music should play!** 🎵

---

## 🔧 Troubleshooting

### "App Remote not connected"
- Make sure **Spotify app is installed** on the device
- Make sure you have **Spotify Premium** (required!)
- Try disconnecting and reconnecting

### "Authorization failed"
- Check your **Client ID** is correct
- Check **Redirect URI** matches in dashboard and code
- Make sure **URL Scheme** is configured correctly

### "No data received" error
- Check your **internet connection**
- Verify backend is running: https://spotify-music-quiz.pages.dev
- Check if you're logged into the web app with the same account

### Build errors
- Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K)
- Delete `Pods` folder and `Podfile.lock`, run `pod install` again
- Make sure you opened `.xcworkspace` not `.xcodeproj`

---

## 🎉 Success!

If everything works, you now have a **fully functional native iOS app** that:
- ✅ Connects to Spotify using official SDK
- ✅ Plays full tracks (not just 30-sec previews)
- ✅ Works on mobile like Hitster
- ✅ Connects to your existing backend

---

## 🚀 Next Steps

- Add more game modes
- Add playlist selection
- Add genre filters
- Customize UI/colors
- Add multiplayer mode
- Publish to App Store!

---

## 📝 Notes

- This is a **native iOS app** - you'll need a separate Android app for Android users
- Requires **Spotify Premium** to play full tracks
- Uses your **existing backend** at https://spotify-music-quiz.pages.dev
- All game logic connects to the same API endpoints

---

Need help? Check the code comments or reach out!
