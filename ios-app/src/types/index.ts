// Game State Types
export interface GameState {
  round: number;
  score: number;
  isPlaying: boolean;
  currentTrack: Track | null;
  timeLeft: number;
  duration: number; // 30, 60, or 0 (full song)
  durationLocked: boolean;
  playlistId: string;
  playlistLocked: boolean;
}

// Track Information
export interface Track {
  id: string;
  name: string;
  artists: string;
  uri: string;
  release_year: string;
  album: string;
  preview_url?: string;
}

// Playlist Information
export interface Playlist {
  id: string;
  name: string;
  tracks_total: number;
  images?: SpotifyImage[];
}

export interface SpotifyImage {
  url: string;
  height: number;
  width: number;
}

// API Response Types
export interface PlaylistsResponse {
  playlists: Playlist[];
}

export interface AuthTokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

// Navigation Types
export type RootStackParamList = {
  Login: undefined;
  Game: undefined;
};
