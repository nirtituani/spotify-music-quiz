# 📱 Manual Spotify SDK Setup - Step by Step

Since CocoaPods doesn't work, we'll install the Spotify iOS SDK manually. Follow these exact steps:

---

## Part 1: Download the SDK (5 minutes)

### Step 1: Download from GitHub

1. **Open your browser**
2. Go to: https://github.com/spotify/ios-sdk/releases
3. Click on the **latest release** (should be at the top)
4. Download: **`SpotifyiOS.xcframework.zip`** (or `SpotifyiOS.framework.zip`)
5. **Unzip** the downloaded file (double-click it)
6. You should now have a folder named `SpotifyiOS.xcframework` (or `.framework`)

---

## Part 2: Add SDK to Xcode (10 minutes)

### Step 2: Open Your Project

1. **Navigate** to `~/Desktop/SpotifyQuizNative/`
2. **Double-click** `SpotifyQuizNative.xcodeproj` to open in Xcode

### Step 3: Add the Framework

1. In Xcode's **left sidebar** (Project Navigator), click the **blue project icon** at the very top (says "SpotifyQuizNative")
2. In the main editor area, make sure **"SpotifyQuizNative"** is selected under **TARGETS** (not PROJECTS)
3. Click the **"General"** tab at the top
4. Scroll down to **"Frameworks, Libraries, and Embedded Content"** section
5. Click the **"+"** button
6. Click **"Add Other..."** dropdown → Select **"Add Files..."**
7. **Navigate** to where you unzipped SpotifyiOS.xcframework
8. **Select** the entire `SpotifyiOS.xcframework` folder
9. Click **"Open"**
10. In the list, make sure the dropdown next to SpotifyiOS says **"Embed & Sign"** (not "Do Not Embed")

✅ You should now see SpotifyiOS.xcframework in the list!

---

### Step 4: Configure Build Settings

1. Still in your target settings, click **"Build Settings"** tab (next to "General")
2. In the search bar at the top, type: **`Other Linker Flags`**
3. Find **"Other Linker Flags"** in the results
4. **Double-click** on the value area (might say "$(inherited)")
5. Click the **"+"** button at the bottom left
6. Type: **`-ObjC`** (exact capitalization!)
7. Press **Enter**
8. Click outside the dialog to close it

✅ Done!

---

### Step 5: Add Bridging Header

#### 5a. Add the Header File

1. In the left sidebar, **right-click** on the **"SpotifyQuizNative"** blue folder (NOT the project icon)
2. Select **"New File..."**
3. Choose **"Header File"**
4. Click **"Next"**
5. Name it: **`SpotifyQuizNative-Bridging-Header.h`** (exact name!)
6. Click **"Create"**

#### 5b. Edit the Header File

1. **Double-click** the file you just created to open it
2. **Delete** everything inside
3. **Paste** this exact content:

```objc
//
//  SpotifyQuizNative-Bridging-Header.h
//  SpotifyQuizNative
//
//  Bridging header to import Spotify iOS SDK into Swift
//

#import <SpotifyiOS/SpotifyiOS.h>
```

4. Press **Cmd+S** to save

#### 5c. Link the Bridging Header

1. Click the **blue project icon** again at the top of the sidebar
2. Select your **target** "SpotifyQuizNative"
3. Go to **"Build Settings"** tab
4. In the search bar, type: **`Bridging Header`**
5. Find **"Objective-C Bridging Header"**
6. **Double-click** the value area
7. Type: **`SpotifyQuizNative/SpotifyQuizNative-Bridging-Header.h`**
8. Press **Enter**

✅ Bridging header configured!

---

### Step 6: Configure Info.plist

1. In the left sidebar, find **`Info.plist`**
2. **Right-click** on it → **"Open As"** → **"Source Code"**
3. Find the line that says `<dict>` near the top
4. **Right after** that line, add this:

```xml
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>spotify</string>
	</array>
```

5. Press **Cmd+S** to save

---

### Step 7: Add URL Scheme (if not done already)

1. Click the **blue project icon** at top of sidebar
2. Select your **target** "SpotifyQuizNative"
3. Go to **"Info"** tab
4. Expand **"URL Types"** section
5. If you don't see an entry with `spotifyquiznative`:
   - Click **"+"** to add new URL Type
   - **Identifier**: `com.spotify.sdk`
   - **URL Schemes**: `spotifyquiznative`
   - **Role**: Editor

✅ URL scheme configured!

---

## Part 3: Update Client ID & Build

### Step 8: Add Your Spotify Client ID

1. In the left sidebar, find and open **`SpotifyManager.swift`**
2. Find the line: `private let clientID = "YOUR_SPOTIFY_CLIENT_ID"`
3. Replace `"YOUR_SPOTIFY_CLIENT_ID"` with your actual Client ID from Spotify Dashboard
4. It should look like: `private let clientID = "abc123def456..."`
5. Press **Cmd+S** to save

---

### Step 9: Build the Project

1. Select a simulator or device from the dropdown at top (next to "SpotifyQuizNative")
2. Press **Cmd+B** to build
3. Wait for the build to complete...

**If successful**, you'll see "Build Succeeded" ✅

**If you get errors**, let me know what they say!

---

## Part 4: Test the App

### Step 10: Run the App

1. Press **Cmd+R** (or click the ▶️ Play button)
2. The app should launch in the simulator or on your device
3. Test the login flow:
   - Click "Login with Spotify"
   - You may need the Spotify app installed on the device
   - Or it will open in Safari for web login

---

## 🎉 Success!

If everything works, you now have a fully functional native iOS app with the Spotify SDK!

---

## 🐛 Common Errors & Fixes

### "No such module 'SpotifyiOS'"
- Make sure you set the Bridging Header path correctly
- Clean build: **Product → Clean Build Folder** (Shift+Cmd+K)
- Try building again

### "'SpotifyiOS/SpotifyiOS.h' file not found"
- Make sure the framework is set to "Embed & Sign"
- Check that you added the framework correctly in Step 3

### Build errors about linking
- Make sure you added `-ObjC` to Other Linker Flags
- Check the capitalization (it's case-sensitive!)

### App crashes on launch
- Make sure you added `spotify` to LSApplicationQueriesSchemes in Info.plist
- Make sure URL scheme is configured

---

## 📝 Summary Checklist

Before running, make sure you've done ALL of these:

- [ ] Downloaded SpotifyiOS.xcframework
- [ ] Added framework to project (Embed & Sign)
- [ ] Added `-ObjC` to Other Linker Flags
- [ ] Created bridging header file
- [ ] Set bridging header path in Build Settings
- [ ] Added `spotify` to Info.plist LSApplicationQueriesSchemes
- [ ] Added URL scheme `spotifyquiznative`
- [ ] Added your Spotify Client ID to SpotifyManager.swift
- [ ] Built successfully (Cmd+B)

---

Need help? Go through the checklist and let me know which step is causing issues!
