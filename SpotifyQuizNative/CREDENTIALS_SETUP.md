# Spotify Credentials Setup

## First Time Setup

1. **Copy the template file:**
   ```bash
   cp ~/spotify-music-quiz/SpotifyQuizNative/SpotifyConfig.swift.template ~/Desktop/SpotifyQuizNative/SpotifyQuizNative/SpotifyConfig.swift
   ```

2. **Edit SpotifyConfig.swift:**
   - Open it in Xcode or any text editor
   - Replace `"YOUR_SPOTIFY_CLIENT_ID"` with your actual Client ID from:
     https://developer.spotify.com/dashboard

3. **Add to Xcode project:**
   - Right-click SpotifyQuizNative folder in Xcode
   - "Add Files to 'SpotifyQuizNative'..."
   - Select `SpotifyConfig.swift`
   - ✅ Check "Add to targets: SpotifyQuizNative"

4. **Your credentials are safe!**
   - `SpotifyConfig.swift` is in `.gitignore`
   - Your Client ID will never be committed to git
   - When you pull updates, your credentials stay intact

## After Pulling New Changes

Your `SpotifyConfig.swift` file won't be affected by git pulls - it's gitignored!
No need to re-enter your Client ID anymore. 🎉
