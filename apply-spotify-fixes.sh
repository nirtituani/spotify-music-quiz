#!/bin/bash
# Apply Spotify SDK fixes to iOS app

echo "🔧 Applying Spotify SDK Fixes..."
echo ""

cd ~/spotify-music-quiz/SpotifyQuizApp || exit 1

# Backup original files
echo "📦 Creating backups..."
cp ios/SpotifyQuizApp/AppDelegate.mm ios/SpotifyQuizApp/AppDelegate.mm.backup
cp ios/Podfile ios/Podfile.backup

# Fix AppDelegate.mm
echo "🔨 Fixing AppDelegate.mm..."
cat > ios/SpotifyQuizApp/AppDelegate.mm << 'ENDOFFILE'
#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <RNSpotifyRemoteAuth.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"SpotifyQuizApp";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self getBundleURL];
}

- (NSURL *)getBundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

// Handle Spotify OAuth callback
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)URL
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
  return [[RNSpotifyRemoteAuth sharedInstance] application:application openURL:URL options:options];
}

@end
ENDOFFILE

# Fix Podfile
echo "🔨 Fixing Podfile..."
cat > ios/Podfile << 'ENDOFFILE'
# Resolve react_native_pods.rb with node to allow for hoisting
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

# If you are using a `react-native-flipper` your iOS build will fail when `NO_FLIPPER=1` is set.
# because `react-native-flipper` depends on (FlipperKit,...) that will be excluded
#
# To fix this you can also exclude `react-native-flipper` using a `react-native.config.js`
# ```js
# module.exports = {
#   dependencies: {
#     ...(process.env.NO_FLIPPER ? { 'react-native-flipper': { platforms: { ios: null } } } : {}),
# ```
flipper_config = FlipperConfiguration.disabled

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end

target 'SpotifyQuizApp' do
  config = use_native_modules!

  # Spotify Remote SDK - must be added manually
  pod 'RNSpotifyRemote', :path => '../node_modules/react-native-spotify-remote'

  use_react_native!(
    :path => config[:reactNativePath],
    # Enables Flipper.
    #
    # Note that if you have use_frameworks! enabled, Flipper will not work and
    # you should disable the next line.
    :flipper_configuration => flipper_config,
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  target 'SpotifyQuizAppTests' do
    inherit! :complete
    # Pods for testing
  end

  post_install do |installer|
    # https://github.com/facebook/react-native/blob/main/packages/react-native/scripts/react_native_pods.rb#L197-L202
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false
    )
  end
end
ENDOFFILE

echo ""
echo "✅ Files updated!"
echo ""
echo "📦 Now reinstalling pods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo ""
echo "🎉 Done! Now run:"
echo "   npm start -- --reset-cache"
echo ""
echo "Then in another terminal:"
echo "   npx react-native run-ios"
