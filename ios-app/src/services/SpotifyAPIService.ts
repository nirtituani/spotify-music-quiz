import axios from 'axios';
import SpotifyAuthService from './SpotifyAuthService';
import { Track, Playlist, PlaylistsResponse } from '../types';

const BACKEND_URL = 'https://spotify-music-quiz.pages.dev';

export class SpotifyAPIService {
  private static instance: SpotifyAPIService;

  private constructor() {}

  static getInstance(): SpotifyAPIService {
    if (!SpotifyAPIService.instance) {
      SpotifyAPIService.instance = new SpotifyAPIService();
    }
    return SpotifyAPIService.instance;
  }

  // Get user's playlists
  async getPlaylists(): Promise<Playlist[]> {
    try {
      const token = await SpotifyAuthService.getAccessToken();
      if (!token) {
        throw new Error('Not authenticated');
      }

      const response = await axios.get<PlaylistsResponse>(
        `${BACKEND_URL}/api/playlists`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      return response.data.playlists;
    } catch (error) {
      console.error('Error fetching playlists:', error);
      return [];
    }
  }

  // Get random track (from playlist or random)
  async getRandomTrack(playlistId?: string): Promise<Track | null> {
    try {
      const token = await SpotifyAuthService.getAccessToken();
      if (!token) {
        throw new Error('Not authenticated');
      }

      let url = `${BACKEND_URL}/api/random-track`;
      if (playlistId && playlistId !== 'random') {
        url += `?playlist_id=${playlistId}`;
      }

      const response = await axios.get<Track>(url, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      return response.data;
    } catch (error) {
      console.error('Error fetching random track:', error);
      return null;
    }
  }

  // Get random track for mobile (alternative endpoint)
  async getRandomTrackMobile(playlistId?: string): Promise<Track | null> {
    try {
      const token = await SpotifyAuthService.getAccessToken();
      if (!token) {
        throw new Error('Not authenticated');
      }

      let url = `${BACKEND_URL}/api/mobile/random-track`;
      if (playlistId && playlistId !== 'random') {
        url += `?playlist_id=${playlistId}`;
      }

      const response = await axios.get<Track>(url, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      return response.data;
    } catch (error) {
      console.error('Error fetching random track (mobile):', error);
      return null;
    }
  }
}

export default SpotifyAPIService.getInstance();
