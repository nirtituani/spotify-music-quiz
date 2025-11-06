# iOS Info.plist Configuration

After creating the iOS project with React Native CLI, you'll need to manually configure the Info.plist file for URL scheme support.

## Steps to Configure Info.plist

1. Open your project in Xcode:
   ```bash
   open ios/SpotifyMusicQuiz.xcworkspace
   ```

2. In Xcode, select your project in the navigator (left sidebar)

3. Select the "SpotifyMusicQuiz" target

4. Go to the "Info" tab

5. Find "URL Types" section (you may need to expand it)

6. Click the "+" button to add a new URL Type

7. Configure the URL Type:
   - **Identifier**: `com.spotifymusicquiz`
   - **URL Schemes**: `spotifymusicquiz`
   - **Role**: Editor

8. Save the changes (Cmd+S)

## Expected Result in Info.plist XML

The configuration will add this to your Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.spotifymusicquiz</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>spotifymusicquiz</string>
        </array>
    </dict>
</array>
```

## Verification

After configuration:
1. The app will be able to handle deep links: `spotifymusicquiz://callback`
2. Spotify OAuth will redirect back to your app after authentication
3. Test by opening Safari and entering: `spotifymusicquiz://test` - it should open your app

## Troubleshooting

- If deep linking doesn't work, ensure the URL scheme is **exactly** `spotifymusicquiz` (no spaces, correct spelling)
- Verify that the Spotify Developer Dashboard has `spotifymusicquiz://callback` as a redirect URI
- Clean build folder (Xcode → Product → Clean Build Folder) and rebuild

## Additional Info.plist Settings

You may also want to add:

### App Transport Security (for HTTP requests)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Permissions (if needed later)
```xml
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library to play songs.</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features.</string>
```

These can be added later if needed.
