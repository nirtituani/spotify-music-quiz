import SpotifyAuthService from './SpotifyAuthService';
import { remote as SpotifyRemote } from 'react-native-spotify-remote';

// Spotify Remote SDK Configuration
const SPOTIFY_CLIENT_ID = '91aaf59fbaec4f1da13157f1fd9a874e';
const SPOTIFY_REDIRECT_URL = 'spotifymusicquiz://callback';

export class SpotifyPlayerService {
  private static instance: SpotifyPlayerService;
  private isConnected: boolean = false;
  private isInitialized: boolean = false;

  private constructor() {}

  static getInstance(): SpotifyPlayerService {
    if (!SpotifyPlayerService.instance) {
      SpotifyPlayerService.instance = new SpotifyPlayerService();
    }
    return SpotifyPlayerService.instance;
  }

  // Initialize Spotify SDK
  async initialize(): Promise<boolean> {
    try {
      if (this.isInitialized) {
        console.log('Spotify SDK already initialized');
        return true;
      }

      const token = await SpotifyAuthService.getAccessToken();
      if (!token) {
        console.error('No access token available');
        return false;
      }

      console.log('Initializing Spotify Remote SDK...');

      // Check if Spotify app is installed
      const isSpotifyAppInstalled = await SpotifyRemote.isSpotifyAppInstalled();
      if (!isSpotifyAppInstalled) {
        console.error('Spotify app is not installed');
        return false;
      }

      // Connect to Spotify Remote
      await SpotifyRemote.connect(token);
      
      console.log('Spotify SDK initialized successfully');
      this.isInitialized = true;
      this.isConnected = true;
      return true;
    } catch (error) {
      console.error('Failed to initialize Spotify SDK:', error);
      this.isInitialized = false;
      this.isConnected = false;
      return false;
    }
  }

  // Play a track by URI
  async playTrack(trackUri: string): Promise<boolean> {
    try {
      if (!this.isConnected) {
        console.error('Spotify not connected, attempting to reconnect...');
        const initialized = await this.initialize();
        if (!initialized) {
          return false;
        }
      }

      console.log('Playing track:', trackUri);
      await SpotifyRemote.playUri(trackUri);
      
      console.log('Track playing successfully');
      return true;
    } catch (error) {
      console.error('Error playing track:', error);
      return false;
    }
  }

  // Pause playback
  async pause(): Promise<void> {
    try {
      if (!this.isConnected) {
        console.log('Not connected, skipping pause');
        return;
      }

      console.log('Pausing playback...');
      await SpotifyRemote.pause();
      console.log('Playback paused');
    } catch (error) {
      console.error('Error pausing:', error);
    }
  }

  // Stop playback (same as pause for Spotify)
  async stop(): Promise<void> {
    try {
      if (!this.isConnected) {
        console.log('Not connected, skipping stop');
        return;
      }

      console.log('Stopping playback...');
      await SpotifyRemote.pause();
      console.log('Playback stopped');
    } catch (error) {
      console.error('Error stopping:', error);
    }
  }

  // Resume playback
  async resume(): Promise<void> {
    try {
      if (!this.isConnected) {
        console.log('Not connected, cannot resume');
        return;
      }

      console.log('Resuming playback...');
      await SpotifyRemote.resume();
      console.log('Playback resumed');
    } catch (error) {
      console.error('Error resuming:', error);
    }
  }

  // Get playback state
  async getPlayerState(): Promise<any> {
    try {
      if (!this.isConnected) {
        return null;
      }

      const state = await SpotifyRemote.getPlayerState();
      return state;
    } catch (error) {
      console.error('Error getting player state:', error);
      return null;
    }
  }

  // Disconnect
  async disconnect(): Promise<void> {
    try {
      if (this.isConnected) {
        console.log('Disconnecting from Spotify...');
        await SpotifyRemote.disconnect();
      }
      
      this.isConnected = false;
      this.isInitialized = false;
      console.log('Disconnected from Spotify');
    } catch (error) {
      console.error('Error disconnecting:', error);
    }
  }

  // Check if connected
  isPlayerConnected(): boolean {
    return this.isConnected;
  }
}

export default SpotifyPlayerService.getInstance();
