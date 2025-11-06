import { authorize, AuthConfiguration } from 'react-native-app-auth';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import { AuthTokenResponse } from '../types';

const BACKEND_URL = 'https://spotify-music-quiz.pages.dev';

// Spotify OAuth Configuration
const spotifyAuthConfig: AuthConfiguration = {
  clientId: 'YOUR_SPOTIFY_CLIENT_ID', // Will be set in setup
  redirectUrl: 'spotifymusicquiz://callback',
  scopes: [
    'streaming',
    'user-read-email',
    'user-read-private',
    'user-modify-playback-state',
    'user-read-playback-state',
    'playlist-read-private',
    'playlist-read-collaborative',
  ],
  serviceConfiguration: {
    authorizationEndpoint: 'https://accounts.spotify.com/authorize',
    tokenEndpoint: 'https://accounts.spotify.com/api/token',
  },
};

export class SpotifyAuthService {
  private static instance: SpotifyAuthService;
  private accessToken: string | null = null;
  private refreshToken: string | null = null;

  private constructor() {}

  static getInstance(): SpotifyAuthService {
    if (!SpotifyAuthService.instance) {
      SpotifyAuthService.instance = new SpotifyAuthService();
    }
    return SpotifyAuthService.instance;
  }

  // Login with Spotify
  async login(): Promise<boolean> {
    try {
      console.log('Starting Spotify OAuth...');
      
      const result = await authorize(spotifyAuthConfig);
      console.log('OAuth successful, got authorization code');

      // Exchange code for token using our backend
      const response = await axios.post<AuthTokenResponse>(
        `${BACKEND_URL}/api/auth/token`,
        {
          code: result.authorizationCode,
          redirect_uri: spotifyAuthConfig.redirectUrl,
        }
      );

      console.log('Token exchange successful');

      this.accessToken = response.data.access_token;
      this.refreshToken = response.data.refresh_token;

      // Save tokens to AsyncStorage
      await AsyncStorage.setItem('spotify_access_token', this.accessToken);
      await AsyncStorage.setItem('spotify_refresh_token', this.refreshToken);
      await AsyncStorage.setItem(
        'token_expiry',
        (Date.now() + response.data.expires_in * 1000).toString()
      );

      console.log('Tokens saved to AsyncStorage');
      return true;
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  }

  // Logout
  async logout(): Promise<void> {
    this.accessToken = null;
    this.refreshToken = null;
    await AsyncStorage.multiRemove([
      'spotify_access_token',
      'spotify_refresh_token',
      'token_expiry',
    ]);
    console.log('Logged out');
  }

  // Get access token (checks if still valid)
  async getAccessToken(): Promise<string | null> {
    if (!this.accessToken) {
      // Try to load from AsyncStorage
      this.accessToken = await AsyncStorage.getItem('spotify_access_token');
      this.refreshToken = await AsyncStorage.getItem('spotify_refresh_token');
    }

    if (!this.accessToken) {
      return null;
    }

    // Check if token is expired
    const expiryStr = await AsyncStorage.getItem('token_expiry');
    if (expiryStr) {
      const expiry = parseInt(expiryStr, 10);
      if (Date.now() > expiry) {
        console.log('Token expired, need to refresh');
        // TODO: Implement token refresh
        return null;
      }
    }

    return this.accessToken;
  }

  // Check if user is logged in
  async isLoggedIn(): Promise<boolean> {
    const token = await this.getAccessToken();
    return token !== null;
  }
}

export default SpotifyAuthService.getInstance();
