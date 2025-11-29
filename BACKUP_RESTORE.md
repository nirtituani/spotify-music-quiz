# Backup & Restore Guide

## 📌 Stable Checkpoint: v1.0-ios-working

This checkpoint represents a **fully working iOS native app** with all features implemented and tested.

---

## ✅ What's Included in This Checkpoint

### **iOS Native App:**
- ✅ Native Swift/SwiftUI app
- ✅ Official Spotify iOS SDK integration
- ✅ OAuth authentication (working)
- ✅ Spotify App Remote connection (established)
- ✅ Full playlist selection:
  - Random from Spotify
  - 27 curated playlists (decades, genres, themes, regional)
  - User's personal Spotify playlists
- ✅ Song duration selector (30s / 60s)
- ✅ Game UI with timer, scoring, and playback control
- ✅ Backend API integration working
- ✅ Credentials management (SpotifyConfig.swift gitignored)

### **Backend API:**
- ✅ Cloudflare Pages deployment
- ✅ Spotify OAuth endpoints
- ✅ Random track fetching
- ✅ Playlist support (user + genre-based)
- ✅ Preview URL testing endpoint

---

## 🔄 How to Restore to This Checkpoint

### **Option 1: Restore Entire Repository**

```bash
cd ~/spotify-music-quiz
git fetch --tags
git checkout v1.0-ios-working
```

### **Option 2: Create a New Branch from This Checkpoint**

```bash
cd ~/spotify-music-quiz
git fetch --tags
git checkout -b restore-ios-working v1.0-ios-working
```

### **Option 3: View Changes Since This Checkpoint**

```bash
cd ~/spotify-music-quiz
git log v1.0-ios-working..HEAD
```

### **Option 4: Hard Reset to This Checkpoint (⚠️ Destructive)**

```bash
cd ~/spotify-music-quiz
git fetch --tags
git reset --hard v1.0-ios-working
git push origin main --force  # Only if you want to update remote
```

---

## 📱 Restore iOS App Files

After checking out the tag, copy files to your Xcode project:

```bash
# Navigate to repo
cd ~/spotify-music-quiz

# Pull the tagged version
git checkout v1.0-ios-working

# Copy all iOS files to Xcode project
cp -r SpotifyQuizNative/* ~/Desktop/SpotifyQuizNative/SpotifyQuizNative/

# Don't forget to restore your credentials!
# (SpotifyConfig.swift is gitignored, so you'll need to recreate it)
```

---

## 🔑 Restore Credentials

The `SpotifyConfig.swift` file is **gitignored** for security, so you need to recreate it:

```bash
# Copy the template
cp ~/spotify-music-quiz/SpotifyQuizNative/SpotifyConfig.swift.template ~/Desktop/SpotifyQuizNative/SpotifyQuizNative/SpotifyConfig.swift

# Edit it and add your actual Client ID
# Replace "YOUR_SPOTIFY_CLIENT_ID" with your real Client ID from:
# https://developer.spotify.com/dashboard
```

---

## 📋 Current File Structure

```
spotify-music-quiz/
├── src/                          # Backend API (Cloudflare Pages)
│   └── index.tsx                 # Main backend with all endpoints
├── SpotifyQuizNative/            # iOS Native App
│   ├── APIManager.swift          # Backend API integration
│   ├── ContentView.swift         # Main menu with playlist/duration selection
│   ├── GameView.swift            # Game screen with timer and controls
│   ├── SpotifyManager.swift      # Spotify SDK integration
│   ├── SpotifyQuizNativeApp.swift # App entry point
│   ├── SpotifyConfig.swift.template # Credentials template
│   ├── Info.plist                # iOS app configuration
│   ├── CREDENTIALS_SETUP.md      # Setup instructions
│   └── MANUAL_SETUP_GUIDE.md     # Manual SDK installation guide
├── dist/                         # Web app build output
├── .gitignore                    # Git ignore rules
└── BACKUP_RESTORE.md             # This file
```

---

## 🏷️ Available Checkpoints

You can list all available checkpoints with:

```bash
cd ~/spotify-music-quiz
git tag -l
```

Current checkpoints:
- **v1.0-ios-working** - Fully functional iOS native app (current)

---

## 🆘 Emergency Recovery

If something goes completely wrong:

1. **Check what changed:**
   ```bash
   cd ~/spotify-music-quiz
   git status
   git diff
   ```

2. **Discard all local changes:**
   ```bash
   git reset --hard HEAD
   git clean -fd
   ```

3. **Return to the working checkpoint:**
   ```bash
   git checkout v1.0-ios-working
   ```

4. **Create a recovery branch:**
   ```bash
   git checkout -b recovery-branch
   ```

---

## 📝 Notes

- **Credentials**: Always keep a copy of your `SpotifyConfig.swift` somewhere safe
- **Spotify Dashboard**: Document your Client ID, Bundle ID, and Redirect URIs
- **Testing**: After restoration, test login, playlist loading, and playback
- **Xcode**: You may need to clean build folder (Cmd+Shift+K) after restoring

---

## ✅ Verification Checklist

After restoring, verify:

- [ ] iOS app builds successfully in Xcode
- [ ] Login with Spotify works
- [ ] Green "Connected" status appears
- [ ] Playlists load (Random + Curated + User playlists)
- [ ] Duration selector works (30s / 60s)
- [ ] Game starts and plays music from Spotify app
- [ ] Timer counts down correctly
- [ ] Score updates when revealing answer

---

## 🔗 Important Links

- Spotify Developer Dashboard: https://developer.spotify.com/dashboard
- Spotify iOS SDK Docs: https://developer.spotify.com/documentation/ios
- Cloudflare Pages: https://spotify-music-quiz.pages.dev
- GitHub Repository: https://github.com/nirtituani/spotify-music-quiz

---

**Created:** November 29, 2025  
**Version:** v1.0-ios-working  
**Status:** ✅ Fully Working
