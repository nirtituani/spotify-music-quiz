# iOS App Setup Guide for Mac

This guide will help you set up and run the Spotify Music Quiz iOS app on your Mac with Xcode.

## Prerequisites

Before you begin, make sure you have:

1. **Mac computer** with macOS 12.0 or later
2. **Xcode 14.0+** installed from the Mac App Store
3. **Node.js 18+** installed (check with `node --version`)
4. **CocoaPods** installed (check with `pod --version`)
   ```bash
   sudo gem install cocoapods
   ```
5. **Spotify Premium Account**
6. **Spotify Developer Account** at https://developer.spotify.com/dashboard

## Step 1: Clone the Repository

```bash
# Clone from GitHub
git clone https://github.com/YOUR_USERNAME/spotify-music-quiz.git
cd spotify-music-quiz/ios-app
```

## Step 2: Install Dependencies

```bash
# Install npm packages
npm install

# Install iOS pods (this may take a few minutes)
cd ios
pod install
cd ..
```

**Important**: Always open the `.xcworkspace` file in Xcode, NOT the `.xcodeproj` file.

## Step 3: Configure Spotify Developer Dashboard

1. Go to https://developer.spotify.com/dashboard
2. Click "Create app"
3. Fill in the details:
   - **App name**: Spotify Music Quiz
   - **App description**: A music quiz game using Spotify
   - **Redirect URI**: `spotifymusicquiz://callback`
   - **APIs used**: Check "Web API"
4. Save your app
5. Copy your **Client ID** (you'll need this in the next step)
6. Go to "App Settings" and add these **Redirect URIs**:
   - `spotifymusicquiz://callback`
   - `https://spotify-music-quiz.pages.dev/callback` (for web version)

## Step 4: Configure Spotify Client ID

Open `src/services/SpotifyAuthService.ts` and replace `YOUR_SPOTIFY_CLIENT_ID` with your actual Client ID:

```typescript
const spotifyAuthConfig: AuthConfiguration = {
  clientId: 'abc123xyz789', // Replace with your actual Client ID
  redirectUrl: 'spotifymusicquiz://callback',
  // ...
};
```

## Step 5: Configure iOS URL Scheme

The URL scheme for deep linking should already be configured, but verify:

1. Open `ios/SpotifyMusicQuiz.xcworkspace` in Xcode
2. Select your project in the navigator
3. Go to the "Info" tab
4. Under "URL Types", ensure you have:
   - **Identifier**: `com.spotifymusicquiz.auth`
   - **URL Schemes**: `spotifymusicquiz`

## Step 6: Configure Spotify iOS SDK

### A. Add Spotify SDK to Podfile

The `react-native-spotify-remote` package should handle this automatically, but if you encounter issues, manually add to `ios/Podfile`:

```ruby
target 'SpotifyMusicQuiz' do
  # ... existing pods ...
  
  pod 'SpotifyiOS', '~> 1.2.2'
end
```

Then run:
```bash
cd ios && pod install && cd ..
```

### B. Register Your App with Spotify

1. Go to your Spotify Developer Dashboard
2. In your app settings, add your iOS Bundle Identifier:
   - Default: `com.spotifymusicquiz` (or whatever you set in Xcode)
3. Save changes

## Step 7: Build and Run

### Option A: Run on iOS Simulator

```bash
# Make sure you're in the ios-app directory
npm run ios

# Or specify a simulator
npm run ios -- --simulator="iPhone 15 Pro"
```

### Option B: Run on Physical Device

1. Connect your iPhone via USB
2. Open `ios/SpotifyMusicQuiz.xcworkspace` in Xcode
3. Select your device from the device dropdown
4. Click the "Play" button (or press Cmd+R)

**Note**: For physical devices, you'll need:
- An Apple Developer account (free account works for testing)
- Enable "Developer Mode" on your iPhone (Settings > Privacy & Security > Developer Mode)
- Trust your computer on the iPhone

## Step 8: Test the App

1. **Launch the app** on simulator or device
2. **Tap "Login with Spotify"** - This should open Safari/Chrome
3. **Authorize the app** in the browser
4. **Redirect back** to the app automatically
5. **Select a playlist** and duration
6. **Start Round** - Music should play via Spotify app

## Troubleshooting

### "No Spotify app installed" Error

The Spotify SDK requires the Spotify app to be installed:
- On simulator: Not supported (Spotify app isn't available for simulator)
- On device: Install the Spotify app from the App Store

**Solution**: You'll need to test on a real iPhone with Spotify installed.

### Authentication Redirect Not Working

1. Verify the redirect URI in Spotify Developer Dashboard matches exactly: `spotifymusicquiz://callback`
2. Check URL scheme in Xcode matches: `spotifymusicquiz`
3. Make sure you're using the correct Client ID in `SpotifyAuthService.ts`

### CocoaPods Installation Fails

```bash
# Update CocoaPods repo
pod repo update

# Clean and reinstall
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Metro Bundler Issues

```bash
# Clear Metro cache
npm start -- --reset-cache

# Or manually clear
rm -rf node_modules
rm package-lock.json
npm install
```

### "Command PhaseScriptExecution failed" in Xcode

This usually happens with Flipper or other debug tools:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

## Architecture Overview

### Services

1. **SpotifyAuthService** (`src/services/SpotifyAuthService.ts`)
   - Handles OAuth login flow
   - Token storage and retrieval
   - Token expiry checking

2. **SpotifyAPIService** (`src/services/SpotifyAPIService.ts`)
   - Fetches playlists from backend
   - Gets random tracks
   - Communicates with https://spotify-music-quiz.pages.dev backend

3. **SpotifyPlayerService** (`src/services/SpotifyPlayerService.ts`)
   - Controls music playback via Spotify SDK
   - Play, pause, stop functions
   - **Important**: Requires Spotify app installed

### Screens

1. **LoginScreen** (`src/screens/LoginScreen.tsx`)
   - Initial authentication screen
   - Spotify login button
   - Navigates to GameScreen after successful login

2. **GameScreen** (`src/screens/GameScreen.tsx`)
   - Main game interface
   - Playlist selection (curated + user playlists)
   - Duration selector (30s, 60s, Full Song)
   - Timer and scoring
   - Song reveal after timer/skip

## Key Features

- **32 Curated Playlists**: Decades (50s-2020s), genres (Rock, Pop, Hip Hop), themes (Love Songs, Workout), regional (Israeli, Latin)
- **User Playlists**: Access your own Spotify playlists
- **Duration Lock**: Settings lock after first round
- **Timer System**: Countdown with progress bar
- **Scoring**: Track points across rounds
- **Song Reveal**: Show track info after timer ends

## Backend API Endpoints

The app communicates with the Cloudflare Pages backend:

- **Base URL**: `https://spotify-music-quiz.pages.dev`
- **POST** `/api/auth/token` - Exchange authorization code for access token
- **GET** `/api/playlists` - Get user's playlists (requires Bearer token)
- **GET** `/api/random-track?playlist_id=X` - Get random track (requires Bearer token)
- **GET** `/api/mobile/random-track` - Mobile-specific endpoint

## Native iOS Configuration Files

### Info.plist Changes Needed

Add this to `ios/SpotifyMusicQuiz/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.spotifymusicquiz.auth</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>spotifymusicquiz</string>
    </array>
  </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>spotify</string>
</array>
```

### Build Settings

In Xcode, make sure:
- **Deployment Target**: iOS 13.0 or later
- **Swift Language Version**: Swift 5.0
- **Enable Bitcode**: No

## Known Limitations

1. **Simulator Support**: Spotify SDK requires physical device (won't work on simulator)
2. **Spotify Premium Required**: The Spotify SDK only works with Premium accounts
3. **Spotify App Required**: User must have Spotify app installed on device

## Next Steps

After successful setup:

1. **Test all features**: Login, playlist selection, playback, timer
2. **UI Polish**: Refine styles, add animations, improve UX
3. **Error Handling**: Add better error messages and loading states
4. **Testing**: Test on multiple iOS versions and devices
5. **App Store**: Prepare for App Store submission if desired

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review backend logs at https://spotify-music-quiz.pages.dev
3. Check Spotify Developer Dashboard for API issues
4. Verify all redirect URIs are configured correctly

## Resources

- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [Spotify iOS SDK](https://developer.spotify.com/documentation/ios)
- [react-native-spotify-remote](https://github.com/cjam/react-native-spotify-remote)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
