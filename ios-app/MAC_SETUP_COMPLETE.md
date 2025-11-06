# 🎉 iOS App Setup - Ready for Your Mac!

## ✅ What I've Done

### 1. **Configured Spotify Client ID**
- ✅ Added your iOS Client ID: `91aaf59fbaec4f1da13157f1fd9a874e`
- ✅ Set redirect URL: `spotifymusicquiz://callback`

### 2. **Completed Spotify SDK Integration**
- ✅ Integrated `react-native-spotify-remote` in `SpotifyPlayerService.ts`
- ✅ Added full playback controls (play, pause, stop, resume)
- ✅ Added connection handling and error recovery

### 3. **Updated Backend API**
- ✅ `/api/playlists` now supports Authorization header (mobile)
- ✅ `/api/random-track` now supports Authorization header (mobile)
- ✅ All mobile endpoints ready to use

### 4. **All Files Ready**
- ✅ `SpotifyAuthService.ts` - OAuth configured
- ✅ `SpotifyAPIService.ts` - API calls ready
- ✅ `SpotifyPlayerService.ts` - Full SDK integration
- ✅ `GameScreen.tsx` - Complete UI
- ✅ Backend updated and deployed

---

## 🚀 Your Next Steps on Mac

### Step 1: Pull Latest Code from GitHub

```bash
cd /Users/nirtituani/spotify-music-quiz
git pull origin main
```

### Step 2: Navigate to iOS App

```bash
cd ios-app
```

### Step 3: Install Node.js Dependencies

```bash
npm install
```

This will install all React Native packages including `react-native-spotify-remote`.

### Step 4: Install iOS Dependencies (CocoaPods)

```bash
cd ios
pod install
cd ..
```

This will install all native iOS dependencies including Spotify SDK.

**Expected output:**
```
Analyzing dependencies
Downloading dependencies
Installing react-native-spotify-remote (0.3.1)
...
Pod installation complete!
```

### Step 5: Open in Xcode

```bash
open ios/SpotifyMusicQuiz.xcworkspace
```

**IMPORTANT:** Open `.xcworkspace` NOT `.xcodeproj`!

---

## ⚙️ Xcode Configuration

Once Xcode opens:

### 1. **Select Your Team**
- Click on project name in left sidebar
- Select "SpotifyMusicQuiz" target
- Go to "Signing & Capabilities" tab
- Select your Apple ID team

### 2. **Verify URL Scheme** (Should already be configured)
- Go to "Info" tab
- Expand "URL Types"
- Should see:
  - Identifier: `com.spotifymusicquiz`
  - URL Schemes: `spotifymusicquiz`

### 3. **Select Device/Simulator**
- Top toolbar → Select "iPhone 15 Pro" (or any simulator)
- Or connect your iPhone and select it

### 4. **Build and Run**
- Click ▶️ Play button (or press Cmd+R)
- Wait for build to complete
- App should launch on simulator/device

---

## 🎮 Testing the App

### First Launch:

1. **Click "Login with Spotify"**
   - Should redirect to Safari/Spotify login
   - Log in with your Spotify Premium account
   - Authorize the app
   - Should redirect back to app

2. **Select Playlist**
   - Choose from curated playlists (🎲 Random, 💿 90s, etc.)
   - Or your own Spotify playlists

3. **Choose Duration**
   - 30 sec, 60 sec, or Full Song

4. **Start Round**
   - Music should play without showing track info
   - Timer counts down
   - Click "Skip" or wait for timer

5. **Song Reveals**
   - Song name, artist, album shown
   - Score updates

---

## 🔧 Troubleshooting

### "No bundle URL present"
**Solution:** Metro bundler not running
```bash
# In terminal, from ios-app folder:
npm start
```

### "Build Failed - CocoaPods"
**Solution:** Clean and reinstall pods
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### "Code Signing Error"
**Solution:** In Xcode
- Signing & Capabilities → Select your Team
- Or enable "Automatically manage signing"

### "Spotify SDK not connecting"
**Check:**
- Spotify app installed on device/simulator
- Logged into Spotify app
- Spotify Premium account
- Redirect URI matches in Spotify Dashboard

### "No module named RNSpotifyRemote"
**Solution:**
```bash
cd ios
pod install
cd ..
npm start -- --reset-cache
```

---

## 📱 Running on Physical iPhone

### Prerequisites:
1. iPhone connected via USB
2. Trust Mac on iPhone
3. iPhone unlocked

### Steps:
1. In Xcode, select your iPhone from device dropdown
2. If you see "untrusted developer":
   - iPhone Settings → General → VPN & Device Management
   - Trust your developer certificate
3. Click Run (▶️)

---

## 🎯 What's Different from Web Version

| Feature | Web | iOS |
|---------|-----|-----|
| **Auth** | Cookie-based | OAuth with AsyncStorage |
| **Playback** | Web Playback SDK | Spotify Remote SDK |
| **Platform** | Desktop only | iPhone/iPad |
| **App** | Browser | Native app |
| **Backend** | Same API | Same API |

---

## 📊 Project Status

| Component | Status |
|-----------|--------|
| Backend API | ✅ Ready |
| Authentication | ✅ Complete |
| Spotify SDK | ✅ Integrated |
| Game Logic | ✅ Complete |
| UI Design | ✅ Complete |
| iOS Config | ✅ Ready |
| Testing | ⏳ Your turn! |

---

## 🆘 If You Get Stuck

### Check Console Logs:
- In Xcode: View → Debug Area → Show Debug Area
- Look for red errors
- Check for Spotify SDK messages

### Common Log Messages:

✅ **Good:**
```
Starting Spotify OAuth...
OAuth successful, got authorization code
Token exchange successful
Spotify SDK initialized successfully
Playing track: spotify:track:xxxxx
Track playing successfully
```

❌ **Bad:**
```
No access token available
Spotify app is not installed
Failed to initialize Spotify SDK
Error playing track
```

---

## 📞 Need Help?

If something isn't working:

1. **Check the logs** in Xcode Debug Area
2. **Copy the error message**
3. **Let me know** and I'll help debug!

---

## 🎉 Ready to Go!

Everything is configured and ready. Just:

1. ✅ Pull latest code: `git pull origin main`
2. ✅ Install dependencies: `npm install` + `pod install`
3. ✅ Open in Xcode: `open ios/SpotifyMusicQuiz.xcworkspace`
4. ✅ Click Run! ▶️

**Good luck! The app is ready to run! 🚀📱**

---

**Last Updated:** 2025-11-06
**iOS App Version:** 1.2.0
**Backend Version:** 1.1.0
