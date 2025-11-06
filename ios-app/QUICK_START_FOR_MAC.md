# Quick Start Guide for Mac

## What You Just Created

✅ **iOS React Native App** for Spotify Music Quiz
- Location in repo: `/ios-app/` folder
- Framework: React Native 0.73 with TypeScript
- Same features as web version
- Ready for Mac/Xcode setup

## Files Created

### Core App Files
- `App.tsx` - Main navigation component
- `index.js` - Entry point
- `app.json` - App configuration

### Source Code (`src/`)
- **Screens**:
  - `LoginScreen.tsx` - Spotify OAuth login UI
  - `GameScreen.tsx` - Main game with playlist/duration/timer
  
- **Services**:
  - `SpotifyAuthService.ts` - OAuth authentication
  - `SpotifyAPIService.ts` - Backend API calls  
  - `SpotifyPlayerService.ts` - Spotify SDK (needs implementation)

- **Types**:
  - `index.ts` - TypeScript interfaces (GameState, Track, Playlist)

### Configuration
- `package.json` - Dependencies (React Native, Spotify SDK, Navigation)
- `tsconfig.json` - TypeScript config
- `babel.config.js` - Babel preset
- `metro.config.js` - Metro bundler config
- `.gitignore` - Ignore node_modules, iOS build files

### iOS Native
- `ios/Podfile` - CocoaPods dependencies
- `ios/INFO_PLIST_SETUP.md` - URL scheme configuration guide

## What to Do on Your Mac

### 1. Clone the Repository
```bash
git clone https://github.com/nirtituani/spotify-music-quiz.git
cd spotify-music-quiz/ios-app
```

### 2. Follow the Full Setup Guide
Open `IOS_SETUP_README.md` - it has complete step-by-step instructions for:
- Installing Xcode, Node.js, CocoaPods
- Configuring Spotify Developer Dashboard
- Installing dependencies
- Running on simulator or device

### 3. Quick Setup Summary
```bash
# Install dependencies
npm install

# Install iOS pods
cd ios
pod install
cd ..

# Run on simulator
npm run ios
```

## Important Configuration Steps

### Before Running the App:

1. **Spotify Client ID**:
   - Edit `src/services/SpotifyAuthService.ts`
   - Replace `YOUR_SPOTIFY_CLIENT_ID_HERE` with your actual Client ID
   - Use existing web app Client ID OR create new iOS app in Spotify Dashboard

2. **Spotify Dashboard**:
   - Add redirect URI: `spotifymusicquiz://callback`
   - Ensure "iOS SDK" is selected

3. **Xcode URL Scheme**:
   - Open `ios/SpotifyMusicQuiz.xcworkspace`
   - Follow steps in `ios/INFO_PLIST_SETUP.md`
   - Add URL scheme: `spotifymusicquiz`

## Starting a New Conversation

When you start a new conversation on your Mac to continue development:

1. **Choose**: "Existing GitHub Project"

2. **Say**: 
   "I have an existing Spotify Music Quiz project with both web and iOS versions. The repo is at https://github.com/nirtituani/spotify-music-quiz. I need help with the iOS app in the `/ios-app/` folder. Please read IOS_SETUP_README.md first."

3. **Key Files to Reference**:
   - `/ios-app/IOS_SETUP_README.md` - Full setup instructions
   - `/ios-app/QUICK_START_FOR_MAC.md` - This file
   - Web app documentation (if needed for backend reference)

## App Architecture

```
Backend (Cloudflare Pages)
    ↓ HTTPS API Calls
iOS App (React Native)
    ├── LoginScreen → SpotifyAuthService → OAuth Flow
    ├── GameScreen → SpotifyAPIService → Fetch playlists/tracks
    └── Player → SpotifyPlayerService → Spotify SDK (native)
```

## Features Implemented

✅ TypeScript interfaces and types
✅ Navigation stack (Login → Game)
✅ OAuth authentication flow
✅ Backend API integration
✅ Playlist selection (32 curated + user playlists)
✅ Duration selector (30s/60s/Full)
✅ Timer countdown
✅ Score tracking
✅ Settings locking after first round
✅ Layout and UI design

## Features NOT Yet Implemented

❌ Spotify SDK player integration (needs native iOS setup)
❌ Actual music playback
❌ iOS app testing on simulator/device
❌ App Store submission assets (icons, screenshots)

## Next Steps on Mac

1. Follow `IOS_SETUP_README.md` for initial setup
2. Complete Spotify SDK integration in `SpotifyPlayerService.ts`
3. Test on iOS simulator
4. Test on physical iPhone
5. Polish UI/UX
6. Prepare for App Store (if desired)

## Troubleshooting

If you encounter issues:
- Check `IOS_SETUP_README.md` troubleshooting section
- Verify all dependencies are installed
- Ensure Spotify Client ID is configured
- Check Xcode console for error messages
- Try cleaning build: Xcode → Product → Clean Build Folder

## Backend Information

The backend is already deployed and working:
- **URL**: https://spotify-music-quiz.pages.dev
- **Endpoints**: `/api/auth/token`, `/api/playlists`, `/api/random-track`
- **No changes needed** - backend supports both web and mobile

## Repository Structure

```
spotify-music-quiz/
├── src/              # Web app (Hono backend)
├── public/           # Web app static files
├── ios-app/          # NEW: iOS React Native app
│   ├── src/          # iOS source code
│   ├── ios/          # iOS native configuration
│   └── IOS_SETUP_README.md
└── README.md         # Main project documentation
```

## Contact & Support

- **GitHub Repo**: https://github.com/nirtituani/spotify-music-quiz
- **Spotify API Docs**: https://developer.spotify.com/documentation/
- **React Native Docs**: https://reactnative.dev/

Good luck with your iOS development! 🚀📱
