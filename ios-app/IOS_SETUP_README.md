# Spotify Music Quiz - iOS App Setup Guide

This guide will help you set up and run the iOS version of Spotify Music Quiz on your Mac with Xcode.

## Prerequisites

Before starting, ensure you have the following installed on your Mac:

1. **macOS** (Big Sur 11.0 or later recommended)
2. **Xcode** (14.0 or later)
   - Install from Mac App Store
   - After installation, open Xcode and accept the license agreement
3. **Node.js** (18.x or later)
   - Download from https://nodejs.org/
   - Verify: `node --version`
4. **CocoaPods** (1.11 or later)
   - Install: `sudo gem install cocoapods`
   - Verify: `pod --version`
5. **Spotify Premium Account**
   - Required for playback functionality

## Step 1: Clone the Repository

```bash
# Clone the repository (use the same repo as web app)
git clone https://github.com/YOUR_USERNAME/spotify-music-quiz.git
cd spotify-music-quiz/ios-app
```

## Step 2: Spotify Developer Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account
3. Click "Create App"
4. Fill in the details:
   - **App Name**: Spotify Music Quiz iOS
   - **App Description**: Music quiz game for iOS
   - **Redirect URI**: `spotifymusicquiz://callback`
   - **Which API/SDKs are you planning to use?**: Select "iOS SDK"
5. Click "Save"
6. Copy your **Client ID** (you'll need this in Step 4)
7. Go to "Settings" → "Redirect URIs"
8. Add: `spotifymusicquiz://callback`
9. Click "Save"

**Important**: You'll need to use the same Spotify Client ID as your web app if you want shared authentication, OR create a separate iOS-specific app in the Spotify Dashboard.

## Step 3: Install Dependencies

```bash
# Install Node.js dependencies
npm install

# Install iOS dependencies (CocoaPods)
cd ios
pod install
cd ..
```

**Note**: If `pod install` fails, try:
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

## Step 4: Configure Spotify Client ID

Edit `src/services/SpotifyAuthService.ts` and replace the placeholder:

```typescript
const spotifyAuthConfig: AuthConfiguration = {
  clientId: 'YOUR_SPOTIFY_CLIENT_ID_HERE', // ← Replace this
  redirectUrl: 'spotifymusicquiz://callback',
  // ... rest of config
};
```

## Step 5: Configure iOS URL Scheme

1. Open `ios/SpotifyMusicQuiz.xcworkspace` in Xcode (NOT .xcodeproj)
2. Select your project in the navigator
3. Select the "SpotifyMusicQuiz" target
4. Go to the "Info" tab
5. Expand "URL Types"
6. Click "+" to add a new URL Type
7. Set:
   - **Identifier**: `com.spotifymusicquiz`
   - **URL Schemes**: `spotifymusicquiz`
8. Save (Cmd+S)

## Step 6: Configure Spotify SDK

The app uses `react-native-spotify-remote` which requires additional iOS configuration:

1. In Xcode, select your target → "Signing & Capabilities"
2. Ensure you have a valid **Team** selected
3. The **Bundle Identifier** should match your configuration

**Spotify Remote SDK Setup**:
1. The SDK will be installed via CocoaPods (already configured in Podfile)
2. Make sure you've run `pod install` in Step 3
3. The SDK requires iOS 13.0 or later (already set in Podfile)

## Step 7: Run on iOS Simulator

```bash
# Make sure you're in ios-app directory
npm run ios

# Or specify a specific simulator
npm run ios -- --simulator="iPhone 15 Pro"
```

**Alternative**: Open `ios/SpotifyMusicQuiz.xcworkspace` in Xcode and click the Play button.

## Step 8: Run on Physical iPhone Device

1. Connect your iPhone to your Mac via USB
2. Trust your Mac on the iPhone (if prompted)
3. In Xcode:
   - Select your iPhone from the device dropdown (top toolbar)
   - Go to "Signing & Capabilities"
   - Select your development team
   - Xcode will automatically create a provisioning profile
4. Click the Play button in Xcode, or run:
   ```bash
   npm run ios -- --device
   ```

**First Time Setup on Device**:
- iOS will block the app from running
- Go to Settings → General → VPN & Device Management
- Trust your developer certificate
- Return to the app and launch again

## Step 9: Test the App

1. **Login Flow**:
   - Tap "Login with Spotify"
   - You'll be redirected to Spotify in Safari
   - Authorize the app
   - You'll be redirected back to the app

2. **Game Flow**:
   - Select a playlist (curated or your own)
   - Choose duration (30s, 60s, or Full Song)
   - Tap "Start Round"
   - Music plays without showing track info
   - Timer counts down
   - Tap "Skip" or wait for timer to end
   - Song details are revealed

## Troubleshooting

### Issue: "No bundle URL present"
**Solution**: Make sure Metro bundler is running:
```bash
npm start
```

### Issue: "Pod install failed"
**Solution**: 
```bash
cd ios
pod deintegrate
pod repo update
pod install
cd ..
```

### Issue: "Command PhaseScriptExecution failed"
**Solution**: 
1. Clean build folder: Xcode → Product → Clean Build Folder (Cmd+Shift+K)
2. Restart Metro bundler: `npm start -- --reset-cache`

### Issue: "Spotify SDK not connecting"
**Solution**:
1. Ensure Spotify app is installed on your device
2. Log in to Spotify on your device
3. Verify your Spotify account is Premium
4. Check that redirect URI matches in Spotify Dashboard and code

### Issue: "Code signing error"
**Solution**:
1. In Xcode, select your target
2. Go to "Signing & Capabilities"
3. Ensure "Automatically manage signing" is checked
4. Select a valid Team

### Issue: "react-native-spotify-remote not found"
**Solution**:
```bash
cd ios
pod install
cd ..
npm start -- --reset-cache
```

## Backend Configuration

The app connects to your deployed Cloudflare backend:
- **Production URL**: `https://spotify-music-quiz.pages.dev`
- **Endpoints Used**:
  - `POST /api/auth/token` - OAuth token exchange
  - `GET /api/playlists` - Fetch user playlists
  - `GET /api/random-track` - Get random track
  - `GET /api/mobile/random-track` - Mobile-specific endpoint

**No backend changes needed** - the backend already supports mobile clients with Authorization header.

## Project Structure

```
ios-app/
├── src/
│   ├── components/         # Reusable UI components (future)
│   ├── screens/
│   │   ├── LoginScreen.tsx # Login with Spotify
│   │   └── GameScreen.tsx  # Main game screen
│   ├── services/
│   │   ├── SpotifyAuthService.ts   # OAuth authentication
│   │   ├── SpotifyAPIService.ts    # Backend API calls
│   │   └── SpotifyPlayerService.ts # Spotify SDK player
│   ├── types/
│   │   └── index.ts        # TypeScript interfaces
│   └── utils/              # Helper functions (future)
├── ios/                    # Native iOS code
│   ├── Podfile             # CocoaPods dependencies
│   └── SpotifyMusicQuiz.xcworkspace
├── App.tsx                 # Root component with navigation
├── index.js                # Entry point
├── package.json            # Dependencies
└── tsconfig.json           # TypeScript config
```

## Development Workflow

1. **Start Metro Bundler**:
   ```bash
   npm start
   ```

2. **Run on Simulator** (in another terminal):
   ```bash
   npm run ios
   ```

3. **Make Code Changes**:
   - Edit files in `src/`
   - Save files
   - App will automatically reload (Fast Refresh)

4. **Debug**:
   - Press `Cmd+D` in simulator to open developer menu
   - Enable "Debug JS Remotely" to use Chrome DevTools
   - Use `console.log()` to debug

## Next Steps

After basic setup is working:

1. **Implement Full Spotify SDK Integration**:
   - Complete `SpotifyPlayerService.ts` with react-native-spotify-remote
   - Handle connection state properly
   - Implement error handling

2. **Add More Features**:
   - Leaderboard (requires backend updates)
   - Different game modes
   - Custom playlist creation
   - Social sharing

3. **UI/UX Improvements**:
   - Animations and transitions
   - Better loading states
   - Error messages
   - Haptic feedback

4. **Testing**:
   - Test on different iPhone models
   - Test with different Spotify accounts
   - Test edge cases (no internet, Spotify not installed, etc.)

5. **App Store Submission** (when ready):
   - Add app icons (all required sizes)
   - Add launch screen
   - Add privacy policy
   - Create screenshots
   - Submit for review

## Support

- **Backend Issues**: Check https://spotify-music-quiz.pages.dev/
- **Spotify API**: https://developer.spotify.com/documentation/
- **React Native**: https://reactnative.dev/docs/getting-started
- **Spotify SDK**: https://github.com/cjam/react-native-spotify-remote

## Notes

- This is a development build - performance may be slower than production
- Spotify Premium is required for playback functionality
- The app requires internet connection to function
- Backend is already deployed and working - no additional setup needed
- All game logic follows the same rules as the web version

## License

Same as the main Spotify Music Quiz project.
