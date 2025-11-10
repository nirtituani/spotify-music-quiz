import React, {useEffect, useRef, useState} from 'react';
import {SafeAreaView, StyleSheet, Alert, Platform} from 'react-native';
import {WebView} from 'react-native-webview';
import {
  auth as SpotifyAuth,
  remote as SpotifyRemote,
  ApiConfig,
  ApiScope,
} from 'react-native-spotify-remote';

// Spotify App Configuration
const SPOTIFY_CLIENT_ID = 'YOUR_SPOTIFY_CLIENT_ID'; // TODO: Replace with your Spotify Client ID
const SPOTIFY_REDIRECT_URI = 'spotifyquizapp://callback';

// API Scopes needed for playback
const spotifyScopes: ApiScope[] = [
  ApiScope.AppRemoteControlScope,
  ApiScope.UserModifyPlaybackStateScope,
  ApiScope.PlaylistReadPrivateScope,
];

// Spotify API Config
const spotifyConfig: ApiConfig = {
  clientID: SPOTIFY_CLIENT_ID,
  redirectURL: SPOTIFY_REDIRECT_URI,
  tokenRefreshURL: 'https://d27bdda9.spotify-music-quiz.pages.dev/api/auth/token',
  tokenSwapURL: 'https://d27bdda9.spotify-music-quiz.pages.dev/api/auth/token',
  scopes: spotifyScopes,
};

function App(): React.JSX.Element {
  const webViewRef = useRef<WebView>(null);
  const [isSpotifyConnected, setIsSpotifyConnected] = useState(false);

  // Initialize Spotify connection
  useEffect(() => {
    initializeSpotify();
  }, []);

  const initializeSpotify = async () => {
    try {
      console.log('Initializing Spotify...');
      
      // Check if Spotify app is installed
      const isInstalled = await SpotifyRemote.isSpotifyAppInstalled();
      if (!isInstalled) {
        Alert.alert(
          'Spotify Required',
          'Please install the Spotify app to use this quiz.',
          [
            {
              text: 'Cancel',
              style: 'cancel',
            },
            {
              text: 'Install',
              onPress: () => {
                // Open Spotify in App Store
                SpotifyRemote.openSpotifyApp();
              },
            },
          ]
        );
        return;
      }

      // Authorize with Spotify
      const session = await SpotifyAuth.authorize(spotifyConfig);
      console.log('Authorized with Spotify:', session);

      // Connect to Spotify Remote
      await SpotifyRemote.connect(session.accessToken);
      console.log('Connected to Spotify Remote');
      
      setIsSpotifyConnected(true);

      // Send connection status to WebView
      webViewRef.current?.injectJavaScript(`
        window.spotifyNativeConnected = true;
        window.dispatchEvent(new CustomEvent('spotifyNativeReady'));
      `);

    } catch (error: any) {
      console.error('Spotify initialization error:', error);
      Alert.alert(
        'Connection Error',
        'Failed to connect to Spotify. Please try again.',
        [{text: 'OK'}]
      );
    }
  };

  // Handle messages from WebView
  const handleWebViewMessage = async (event: any) => {
    try {
      const message = JSON.parse(event.nativeEvent.data);
      console.log('Received message from WebView:', message);

      switch (message.type) {
        case 'PLAY_TRACK':
          await playTrack(message.trackUri);
          break;

        case 'PAUSE_TRACK':
          await pauseTrack();
          break;

        case 'GET_SPOTIFY_STATUS':
          sendSpotifyStatus();
          break;

        default:
          console.log('Unknown message type:', message.type);
      }
    } catch (error) {
      console.error('Error handling WebView message:', error);
    }
  };

  // Play a track using Spotify Remote
  const playTrack = async (trackUri: string) => {
    try {
      console.log('Playing track:', trackUri);
      
      if (!isSpotifyConnected) {
        console.error('Spotify not connected');
        return;
      }

      await SpotifyRemote.playUri(trackUri);
      console.log('Track started playing');

      // Notify WebView that playback started
      webViewRef.current?.injectJavaScript(`
        window.dispatchEvent(new CustomEvent('spotifyPlaybackStarted', {
          detail: { trackUri: '${trackUri}' }
        }));
      `);

    } catch (error) {
      console.error('Error playing track:', error);
      Alert.alert('Playback Error', 'Failed to play the track.');
    }
  };

  // Pause playback
  const pauseTrack = async () => {
    try {
      console.log('Pausing playback');
      await SpotifyRemote.pause();
      
      // Notify WebView
      webViewRef.current?.injectJavaScript(`
        window.dispatchEvent(new CustomEvent('spotifyPlaybackPaused'));
      `);
    } catch (error) {
      console.error('Error pausing track:', error);
    }
  };

  // Send Spotify connection status to WebView
  const sendSpotifyStatus = () => {
    webViewRef.current?.injectJavaScript(`
      window.spotifyNativeConnected = ${isSpotifyConnected};
      window.dispatchEvent(new CustomEvent('spotifyStatusUpdate', {
        detail: { connected: ${isSpotifyConnected} }
      }));
    `);
  };

  // Inject JavaScript to set up native bridge
  const injectedJavaScript = `
    (function() {
      // Flag to indicate native app is available
      window.isNativeApp = true;
      window.spotifyNativeConnected = false;

      // Function to send messages to React Native
      window.sendToNative = function(type, data) {
        window.ReactNativeWebView.postMessage(JSON.stringify({
          type: type,
          ...data
        }));
      };

      console.log('Native bridge initialized');
    })();
    true; // Required to prevent issues
  `;

  return (
    <SafeAreaView style={styles.container}>
      <WebView
        ref={webViewRef}
        source={{uri: 'https://d27bdda9.spotify-music-quiz.pages.dev'}}
        style={styles.webview}
        javaScriptEnabled={true}
        domStorageEnabled={true}
        startInLoadingState={true}
        scalesPageToFit={true}
        onMessage={handleWebViewMessage}
        injectedJavaScript={injectedJavaScript}
        onLoadEnd={() => {
          console.log('WebView loaded');
          // Send initial Spotify status
          setTimeout(() => sendSpotifyStatus(), 500);
        }}
        onError={(syntheticEvent) => {
          const {nativeEvent} = syntheticEvent;
          console.error('WebView error:', nativeEvent);
        }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  webview: {
    flex: 1,
  },
});

export default App;
