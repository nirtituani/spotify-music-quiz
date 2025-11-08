#!/bin/bash

# Quick Fix Script for iOS Project Setup
# This regenerates the Xcode project file that's missing

set -e  # Exit on error

echo "🔧 Spotify Music Quiz - iOS Project Fix"
echo "========================================"
echo ""

# Check we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from ios-app directory"
    echo "   cd /Users/nirtituani/spotify-music-quiz/ios-app"
    echo "   bash QUICK_FIX.sh"
    exit 1
fi

echo "✅ Step 1: Backing up important files..."
mkdir -p ~/ios-app-backup
cp ios/Podfile ~/ios-app-backup/Podfile.backup 2>/dev/null || echo "No Podfile to backup"
echo "   Backed up to ~/ios-app-backup/"

echo ""
echo "✅ Step 2: Creating temporary React Native project..."
cd ..
npx react-native@0.73.0 init TempSpotifyQuiz --version 0.73.0 --skip-install

echo ""
echo "✅ Step 3: Extracting iOS project files..."
cd spotify-music-quiz/ios-app
rm -rf ios
cp -R ../TempSpotifyQuiz/ios ./ios

echo ""
echo "✅ Step 4: Renaming project..."
cd ios
mv TempSpotifyQuiz SpotifyMusicQuiz
mv TempSpotifyQuiz.xcodeproj SpotifyMusicQuiz.xcodeproj
mv TempSpotifyQuiz.xcworkspace SpotifyMusicQuiz.xcworkspace 2>/dev/null || echo "No workspace yet (will be created by pod install)"

# Update project name in all files
find SpotifyMusicQuiz.xcodeproj -type f -exec sed -i '' 's/TempSpotifyQuiz/SpotifyMusicQuiz/g' {} +
find . -name "*.plist" -exec sed -i '' 's/TempSpotifyQuiz/SpotifyMusicQuiz/g' {} +

echo ""
echo "✅ Step 5: Restoring custom Podfile..."
cd ..
if [ -f ~/ios-app-backup/Podfile.backup ]; then
    cp ~/ios-app-backup/Podfile.backup ios/Podfile
    echo "   Custom Podfile restored"
else
    echo "   No backup found, keeping generated Podfile"
fi

echo ""
echo "✅ Step 6: Cleaning up temp project..."
cd ../..
rm -rf TempSpotifyQuiz

echo ""
echo "✅ Step 7: Installing CocoaPods dependencies..."
cd spotify-music-quiz/ios-app/ios
pod install

echo ""
echo "✅ Step 8: Updating Info.plist for OAuth..."
# Add OAuth URL scheme if not already present
if ! grep -q "spotifymusicquiz" SpotifyMusicQuiz/Info.plist; then
    # Create temporary file with OAuth config
    cat > /tmp/oauth_config.xml << 'EOF'
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
EOF
    # Insert before closing </dict>
    sed -i '' '/<\/dict>$/i\
' SpotifyMusicQuiz/Info.plist
    cat /tmp/oauth_config.xml >> SpotifyMusicQuiz/Info.plist
    echo "</dict>" >> SpotifyMusicQuiz/Info.plist
    echo "</plist>" >> SpotifyMusicQuiz/Info.plist
    echo "   OAuth URL scheme added"
else
    echo "   OAuth URL scheme already present"
fi

echo ""
echo "=========================================="
echo "✅ SUCCESS! iOS project is ready!"
echo ""
echo "Next steps:"
echo "1. Open Xcode workspace:"
echo "   open SpotifyMusicQuiz.xcworkspace"
echo ""
echo "2. Select 'SpotifyMusicQuiz' scheme"
echo "3. Select a simulator (e.g., iPhone 15)"
echo "4. Build: Product → Build (Cmd+B)"
echo ""
echo "If you get any errors, check:"
echo "- Xcode is updated (26.0.1+)"
echo "- Command Line Tools installed"
echo "- Valid Apple Developer account signed in"
echo "=========================================="
