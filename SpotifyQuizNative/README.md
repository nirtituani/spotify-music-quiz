# Spotify Music Quiz - Native iOS App

This is a native iOS app built with **Swift** and the **official Spotify iOS SDK**.

## Why Native Swift?

Unlike React Native wrappers, this uses the official Spotify iOS SDK directly, providing:
- ✅ Reliable Spotify authentication
- ✅ Full track playback (not just 30-second previews)
- ✅ Direct integration with the Spotify app on the device
- ✅ Same approach used by professional apps like Hitster

## Setup Instructions

### Prerequisites

1. **Mac with Xcode** (version 14.0 or later)
2. **CocoaPods** installed (`sudo gem install cocoapods`)
3. **Spotify Premium account** (required for playback)
4. **Spotify Developer credentials** (Client ID from your app dashboard)

### Step 1: Create the Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Product Name: `SpotifyQuizNative`
5. Team: Your Apple Developer Team
6. Organization Identifier: `com.yourname.spotifyquiz` (or your domain)
7. Interface: SwiftUI
8. Language: Swift
9. Click "Create" and save in this folder

### Step 2: Install Spotify iOS SDK via CocoaPods

1. In Terminal, navigate to the project folder:
   ```bash
   cd /path/to/SpotifyQuizNative
   ```

2. Create a `Podfile`:
   ```bash
   pod init
   ```

3. Edit the `Podfile` to include the Spotify SDK:
   ```ruby
   platform :ios, '13.0'
   use_frameworks!

   target 'SpotifyQuizNative' do
     pod 'SpotifyiOS', '~> 1.2.2'
   end
   ```

4. Install the pods:
   ```bash
   pod install
   ```

5. **IMPORTANT**: From now on, open `SpotifyQuizNative.xcworkspace` (NOT .xcodeproj)

### Step 3: Configure Spotify App Settings

1. Go to your [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Select your app
3. Click "Edit Settings"
4. Add Redirect URI:
   ```
   spotifyquiznative://callback
   ```
5. Save

### Step 4: Configure iOS App URL Scheme

1. In Xcode, select your project in the navigator
2. Select the target "SpotifyQuizNative"
3. Go to "Info" tab
4. Expand "URL Types"
5. Click "+" to add a new URL Type:
   - Identifier: `com.spotify.sdk`
   - URL Schemes: `spotifyquiznative`

### Step 5: Update Info.plist

Right-click `Info.plist` → Open As → Source Code, and add:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>spotify</string>
</array>
```

### Step 6: Add the Code Files

I'll provide the Swift code files in the next steps. Copy them into your Xcode project.

## Architecture

```
SpotifyQuizNative/
├── App/
│   ├── SpotifyQuizNativeApp.swift    # App entry point
│   └── ContentView.swift              # Main UI
├── Managers/
│   ├── SpotifyManager.swift           # Spotify SDK integration
│   └── APIManager.swift               # Backend API calls
├── Models/
│   ├── Track.swift                    # Track data model
│   └── GameState.swift                # Game state management
├── Views/
│   ├── LoginView.swift                # Spotify login screen
│   ├── GameView.swift                 # Main game interface
│   └── Components/                    # Reusable UI components
└── Resources/
    └── Assets.xcassets                # App icons, colors, etc.
```

## Features

- ✅ Spotify OAuth authentication
- ✅ Full track playback through Spotify app
- ✅ Connects to your existing backend API
- ✅ Genre/playlist selection
- ✅ Guess the song game mechanics
- ✅ Score tracking

## Backend Integration

The app connects to your existing Cloudflare backend:
- Base URL: `https://spotify-music-quiz.pages.dev`
- Endpoints:
  - `GET /api/random-track` - Get random track
  - `GET /api/user/playlists` - Get user playlists

## Next Steps

Follow the setup instructions above, then I'll provide all the Swift code files you need!
