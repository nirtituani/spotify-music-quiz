# 🔧 Quick Fix Guide: AppAuth Linking Issue

**Problem:** `ld: library not found for -lAppAuth`

**Status:** Solutions 1 and 2 tried, still debugging...

---

## 🎯 Try These Solutions (In Order)

### **Solution 1: Force Static Library Build** ❌ (Tried - Didn't Work)

Edit `ios/Podfile`, add to `post_install`:

```ruby
post_install do |installer|
  react_native_post_install(installer, :mac_catalyst_enabled => false)
  
  # Fix for RNEventEmitter and Spotify SDK
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      
      # Force AppAuth to build as static library
      if target.name == 'AppAuth'
        config.build_settings['MACH_O_TYPE'] = 'staticlib'
        config.build_settings['SKIP_INSTALL'] = 'NO'
      end
    end
  end
  
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
```

Then:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

---

### **Solution 2: Use Frameworks** ❌ (Tried - Didn't Work)

Add to top of Podfile (after `platform :ios`):

```ruby
platform :ios, '13.4'
use_frameworks! :linkage => :static  # Add this line
```

Then:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

**Update:** Also tried removing conflicting MACH_O_TYPE settings. Still didn't resolve the issue.

---

### **Solution 3: Remove Conflicting Settings** ⭐ (Try This Next)

Current Podfile has `use_frameworks!` enabled. Let's clean up the conflicting settings:

**Already done in latest commit (d0da6e1):**
- Removed `MACH_O_TYPE = 'staticlib'` for AppAuth
- Kept `use_frameworks! :linkage => :static`
- Let CocoaPods handle framework building

**Now try:**
```bash
cd /Users/nirtituani/spotify-music-quiz/ios-app
git pull origin main  # Get latest Podfile
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*  # Clean derived data
pod install
```

Then open Xcode and build.

---

### **Solution 4: Manual Build in Xcode**

1. Open `ios/SpotifyMusicQuiz.xcworkspace`
2. Top left scheme selector → Select **"AppAuth"** (click and search)
3. Build (Cmd+B)
4. Wait for build to finish
5. Switch scheme back to **"SpotifyMusicQuiz"**
6. Build again (Cmd+B)

---

### **Solution 5: Check What's Actually There**

```bash
cd /Users/nirtituani/spotify-music-quiz/ios-app/ios

# Check if AppAuth built
find ~/Library/Developer/Xcode/DerivedData -name "libAppAuth.a" 2>/dev/null

# Check AppAuth pod structure
ls -la Pods/AppAuth/
```

If `libAppAuth.a` doesn't exist, AppAuth isn't building.

---

### **Solution 6: Remove react-native-app-auth** (Last Resort)

If nothing works, replace with simple OAuth:

```bash
cd /Users/nirtituani/spotify-music-quiz/ios-app

# Remove the problematic library
npm uninstall react-native-app-auth

cd ios
pod install
```

Then implement OAuth with React Native's `Linking` API instead.

---

## 🔍 Debug Commands

```bash
# Check what CocoaPods thinks AppAuth is
cd /Users/nirtituani/spotify-music-quiz/ios-app/ios
cat Podfile.lock | grep -A 10 "AppAuth"

# Check build log for AppAuth
# In Xcode: View → Navigators → Report Navigator
# Find last build → Search for "AppAuth"
```

---

## 📞 If Still Stuck

Post on:
- https://github.com/FormidableLabs/react-native-app-auth/issues
- Stack Overflow with tag `react-native` `cocoapods` `appauth`

Include:
- Error message
- Xcode version
- React Native version (0.73.0)
- CocoaPods version
- Output of `pod --version` and `ruby --version`

---

**Good luck! Solution 1 has the highest chance of working!** 🍀
