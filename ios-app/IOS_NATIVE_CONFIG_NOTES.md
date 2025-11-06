# iOS Native Configuration Notes

These configuration steps MUST be done on your Mac with Xcode after running `npm install` and `pod install`.

## Important: Project Initialization Required

Before these configurations can be applied, you need to initialize the React Native iOS project:

```bash
# After npm install, create the iOS project structure
npx react-native init SpotifyMusicQuiz --skip-install
# Then replace the generated files with our custom code
```

## 1. Info.plist Configuration

File location: `ios/SpotifyMusicQuiz/Info.plist`

Add these entries:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys ... -->
    
    <!-- URL Scheme for OAuth Callback -->
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
    
    <!-- Allow querying Spotify app -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>spotify</string>
    </array>
    
    <!-- App Transport Security (if needed for development) -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>spotify-music-quiz.pages.dev</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <false/>
                <key>NSIncludesSubdomains</key>
                <true/>
            </dict>
        </dict>
    </dict>
</dict>
</plist>
```

## 2. Podfile Configuration

File location: `ios/Podfile`

The Podfile should include:

```ruby
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

platform :ios, '13.0'
install! 'cocoapods', :deterministic_uuids => false

target 'SpotifyMusicQuiz' do
  config = use_native_modules!

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => true,
  )

  # Spotify Remote SDK
  pod 'react-native-spotify-remote', :path => '../node_modules/react-native-spotify-remote'
  
  # Optional: Add Spotify iOS SDK directly if needed
  # pod 'SpotifyiOS', '~> 1.2.2'

  # Required for react-native-app-auth
  pod 'AppAuth', '~> 1.6'

  target 'SpotifyMusicQuizTests' do
    inherit! :complete
  end

  post_install do |installer|
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false
    )
  end
end
```

After editing Podfile:
```bash
cd ios
pod install
cd ..
```

## 3. AppDelegate Configuration

File location: `ios/SpotifyMusicQuiz/AppDelegate.mm`

Add deep linking support:

```objc
#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLinkingManager.h> // Add this import

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"SpotifyMusicQuiz";
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// Add this method for deep linking
- (BOOL)application:(UIApplication *)application
   openURL:(NSURL *)url
   options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
  return [RCTLinkingManager application:application openURL:url options:options];
}

// Add this method for universal links (optional)
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
  return [RCTLinkingManager application:application
                   continueUserActivity:userActivity
                     restorationHandler:restorationHandler];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
```

## 4. Xcode Project Settings

Open `ios/SpotifyMusicQuiz.xcworkspace` in Xcode and configure:

### General Tab:
- **Display Name**: Spotify Music Quiz
- **Bundle Identifier**: com.spotifymusicquiz (or your custom identifier)
- **Version**: 1.0.0
- **Build**: 1
- **Deployment Target**: iOS 13.0 or later

### Signing & Capabilities:
1. Select your development team
2. Enable "Automatically manage signing"
3. Ensure provisioning profile is valid

### Info Tab:
- Verify URL Types are present (should show after Info.plist edit)
- Verify LSApplicationQueriesSchemes includes "spotify"

### Build Settings:
- **Swift Language Version**: Swift 5.0
- **Enable Bitcode**: No
- **Other Linker Flags**: Add `-ObjC` if not present

## 5. Entitlements (Optional, for App Store)

If you plan to submit to App Store, you may need:

File location: `ios/SpotifyMusicQuiz/SpotifyMusicQuiz.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.spotifymusicquiz</string>
    </array>
</dict>
</plist>
```

## 6. Build Phases (Spotify SDK)

In Xcode:
1. Select your project
2. Select target "SpotifyMusicQuiz"
3. Go to "Build Phases"
4. Verify "Link Binary with Libraries" includes:
   - libSpotifyiOS.a (if using Spotify SDK directly)
   - Or framework from react-native-spotify-remote

## 7. Testing Checklist

Before building:
- [ ] Info.plist has URL scheme "spotifymusicquiz"
- [ ] Info.plist has LSApplicationQueriesSchemes with "spotify"
- [ ] Podfile includes required pods
- [ ] AppDelegate.mm has deep linking methods
- [ ] Bundle identifier matches Spotify Developer Dashboard
- [ ] Redirect URI in code matches Dashboard: `spotifymusicquiz://callback`
- [ ] Spotify Client ID is set in `SpotifyAuthService.ts`

## 8. First Build Steps

```bash
# 1. Install dependencies
npm install

# 2. Install pods
cd ios
pod install
cd ..

# 3. Build for iOS (simulator or device)
npm run ios

# Or manually in Xcode:
# Open ios/SpotifyMusicQuiz.xcworkspace
# Select device/simulator
# Press Cmd+R to build and run
```

## 9. Common Build Errors

### "Module 'react-native-spotify-remote' not found"
```bash
cd ios
pod deintegrate
pod install
cd ..
npm run ios
```

### "No bundle URL present"
```bash
npm start -- --reset-cache
# In another terminal:
npm run ios
```

### "Command PhaseScriptExecution failed"
Usually related to Flipper or code signing:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

## 10. Spotify Developer Dashboard Settings

Ensure these are configured at https://developer.spotify.com/dashboard:

1. **App Name**: Spotify Music Quiz
2. **Redirect URIs**:
   - `spotifymusicquiz://callback` (for iOS app)
   - `https://spotify-music-quiz.pages.dev/callback` (for web)
3. **Bundle IDs** (under iOS settings):
   - `com.spotifymusicquiz` (or your custom identifier)
4. **APIs**: Web API enabled

## Notes

- The iOS project structure (`ios/` folder) will be generated when you run `npm install` with React Native
- Some files (AppDelegate.mm, Info.plist) will be created by React Native init
- You'll need to manually edit these files to add the configurations above
- Always use `.xcworkspace` not `.xcodeproj` when opening in Xcode
- Physical device required for testing (Spotify SDK doesn't work on simulator)
