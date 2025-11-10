# Spotify Quiz App - Hybrid WebView + Native Playback Setup Guide

This app uses a **hybrid approach**: WebView for the UI and native Spotify SDK for audio playback.

## Prerequisites

1. **Spotify Developer Account**: https://developer.spotify.com/dashboard
2. **Spotify Premium Account**: Required for playback
3. **Spotify App Installed**: On your iOS device/simulator

## Setup Steps

### 1. Register Your App on Spotify Developer Dashboard

1. Go to: https://developer.spotify.com/dashboard
2. Click "Create app"
3. Fill in the details:
   - **App name**: Spotify Quiz App
   - **App description**: Music quiz game
   - **Redirect URI**: `spotifyquizapp://callback`
   - **API**: Check "iOS SDK"
4. Save and copy your **Client ID**

### 2. Configure the App with Your Spotify Client ID

Edit `SpotifyQuizApp/App.tsx` and replace:

```typescript
const SPOTIFY_CLIENT_ID = 'YOUR_SPOTIFY_CLIENT_ID';
```

With your actual Client ID from step 1.

### 3. Install Dependencies

```bash
cd SpotifyQuizApp

# Install npm packages
npm install

# Install iOS pods
cd ios
pod install
cd ..
```

### 4. Run the App

#### Option A: Using React Native CLI

```bash
# Start Metro bundler in one terminal
npm start

# In another terminal, run iOS
npx react-native run-ios
```

#### Option B: Using Xcode

1. Open `ios/SpotifyQuizApp.xcworkspace` in Xcode
2. Select your device/simulator
3. Click Run (⌘R)

## How It Works

### Architecture

```
┌─────────────────────────────────────┐
│     React Native App (App.tsx)      │
│  ┌─────────────────────────────┐   │
│  │   WebView (Game UI)          │   │
│  │   - Display game interface   │   │
│  │   - Handle game logic        │   │
│  │   - Send track URIs          │   │
│  └─────────────────────────────┘   │
│              ↕ Bridge                │
│  ┌─────────────────────────────┐   │
│  │   Spotify Remote SDK         │   │
│  │   - Native audio playback    │   │
│  │   - Connects to Spotify app  │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Communication Flow

1. **WebView → Native**: 
   - When user clicks "Start Round", WebView sends track URI to React Native
   - Message format: `{ type: 'PLAY_TRACK', trackUri: 'spotify:track:xxx' }`

2. **Native → WebView**:
   - Native player notifies WebView when playback starts/stops
   - WebView updates UI accordingly

3. **Playback**:
   - React Native uses Spotify Remote SDK to play tracks
   - Audio plays through native Spotify app (not WebView)

## Troubleshooting

### "Spotify not installed" error
- Install Spotify app from App Store
- Make sure you're logged in to Spotify

### "Authorization failed" error
- Check your Client ID in `App.tsx`
- Verify redirect URI in Spotify Dashboard: `spotifyquizapp://callback`
- Make sure you added the app to your Spotify Dashboard

### "No audio playing" error
- Ensure Spotify Premium account
- Check that Spotify app is not playing on another device
- Try force-quitting and reopening both apps

### Build errors
```bash
# Clean and reinstall
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Clean Metro cache
npm start -- --reset-cache
```

## Testing

1. Open the app
2. App will prompt for Spotify authorization
3. Log in with your Spotify account
4. App connects to Spotify
5. WebView loads the game UI
6. Click "Start Round"
7. Audio should play through native Spotify player!

## Features

✅ WebView-based UI (no need to recreate UI in React Native)
✅ Native Spotify playback (works on mobile)
✅ Seamless bridge between WebView and Native
✅ Premium audio quality
✅ Works offline (if tracks are downloaded in Spotify)

## Development

### Web App (UI)
- Located in: `/public/static/app.js`
- Detects if running in native app via `window.isNativeApp`
- Uses `window.sendToNative()` to communicate with React Native

### React Native App
- Located in: `/SpotifyQuizApp/App.tsx`
- Handles Spotify authentication
- Manages native playback
- Bridges communication with WebView

## Next Steps

1. Submit app to Spotify for approval (for production)
2. Add offline mode support
3. Improve error handling
4. Add push notifications for multiplayer features

## Support

For issues, check:
- [react-native-spotify-remote docs](https://github.com/cjam/react-native-spotify-remote)
- [Spotify iOS SDK docs](https://developer.spotify.com/documentation/ios)
- Project GitHub issues
