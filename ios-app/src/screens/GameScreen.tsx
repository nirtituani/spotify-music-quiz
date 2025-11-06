import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  ScrollView,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList, GameState, Playlist } from '../types';
import SpotifyAuthService from '../services/SpotifyAuthService';
import SpotifyAPIService from '../services/SpotifyAPIService';
import SpotifyPlayerService from '../services/SpotifyPlayerService';

type GameScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'Game'
>;

interface Props {
  navigation: GameScreenNavigationProp;
}

const CURATED_PLAYLISTS = [
  { id: 'random', name: '🎲 Random from Spotify' },
  { id: 'genre:90s', name: '💿 90s Hits' },
  { id: 'genre:00s', name: '📱 2000s Hits' },
  { id: 'genre:rock', name: '🎸 Rock' },
  { id: 'genre:pop', name: '🎤 Pop' },
  { id: 'genre:hip-hop', name: '🎤 Hip Hop' },
  { id: 'genre:israeli', name: '🇮🇱 Israeli Music' },
];

export default function GameScreen({ navigation }: Props) {
  const [gameState, setGameState] = useState<GameState>({
    round: 1,
    score: 0,
    isPlaying: false,
    currentTrack: null,
    timeLeft: 30,
    duration: 30,
    durationLocked: false,
    playlistId: 'random',
    playlistLocked: false,
  });

  const [playlists, setPlaylists] = useState<Playlist[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [showAnswer, setShowAnswer] = useState(false);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // Load playlists on mount
  useEffect(() => {
    loadPlaylists();
    initializePlayer();

    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    };
  }, []);

  const loadPlaylists = async () => {
    const userPlaylists = await SpotifyAPIService.getPlaylists();
    setPlaylists(userPlaylists);
  };

  const initializePlayer = async () => {
    const initialized = await SpotifyPlayerService.initialize();
    if (!initialized) {
      console.warn('Spotify player not initialized');
    }
  };

  const startRound = async () => {
    setIsLoading(true);
    setShowAnswer(false);

    // Lock settings after first round
    if (!gameState.durationLocked) {
      setGameState(prev => ({
        ...prev,
        durationLocked: true,
        playlistLocked: true,
      }));
    }

    try {
      // Fetch random track
      const track = await SpotifyAPIService.getRandomTrack(gameState.playlistId);
      
      if (!track) {
        Alert.alert('Error', 'Could not load track. Please try again.');
        setIsLoading(false);
        return;
      }

      // Play track
      const played = await SpotifyPlayerService.playTrack(track.uri);
      
      if (!played) {
        Alert.alert('Error', 'Could not play track. Make sure Spotify app is open.');
        setIsLoading(false);
        return;
      }

      // Update game state
      setGameState(prev => ({
        ...prev,
        currentTrack: track,
        isPlaying: true,
        timeLeft: prev.duration,
      }));

      // Start timer (if not full song mode)
      if (gameState.duration > 0) {
        startTimer();
      }

      setIsLoading(false);
    } catch (error) {
      console.error('Error starting round:', error);
      Alert.alert('Error', 'Failed to start round');
      setIsLoading(false);
    }
  };

  const startTimer = () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
    }

    timerRef.current = setInterval(() => {
      setGameState(prev => {
        const newTimeLeft = prev.timeLeft - 1;
        
        if (newTimeLeft <= 0) {
          endRound(true); // Timer ended, give point
          return prev;
        }
        
        return { ...prev, timeLeft: newTimeLeft };
      });
    }, 1000);
  };

  const skipRound = () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
    }
    endRound(false); // Skipped, no point
  };

  const endRound = async (earnedPoint: boolean) => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
    }

    await SpotifyPlayerService.pause();

    setGameState(prev => ({
      ...prev,
      isPlaying: false,
      score: earnedPoint ? prev.score + 1 : prev.score,
      round: prev.round + 1,
    }));

    setShowAnswer(true);
  };

  const handleLogout = async () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Logout',
          style: 'destructive',
          onPress: async () => {
            await SpotifyAuthService.logout();
            await SpotifyPlayerService.disconnect();
            navigation.replace('Login');
          },
        },
      ]
    );
  };

  const renderPlaylistPicker = () => {
    const allPlaylists = [...CURATED_PLAYLISTS, ...playlists];
    
    return (
      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false}
        style={styles.playlistScroll}
      >
        {allPlaylists.map(playlist => (
          <TouchableOpacity
            key={playlist.id}
            style={[
              styles.playlistChip,
              gameState.playlistId === playlist.id && styles.playlistChipSelected,
              gameState.playlistLocked && styles.playlistChipDisabled,
            ]}
            onPress={() => {
              if (!gameState.playlistLocked) {
                setGameState(prev => ({ ...prev, playlistId: playlist.id }));
              }
            }}
            disabled={gameState.playlistLocked}
          >
            <Text
              style={[
                styles.playlistChipText,
                gameState.playlistId === playlist.id && styles.playlistChipTextSelected,
              ]}
            >
              {playlist.name}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>
    );
  };

  const renderDurationPicker = () => {
    const durations = [
      { value: 30, label: '30 sec' },
      { value: 60, label: '60 sec' },
      { value: 0, label: 'Full Song' },
    ];

    return (
      <View style={styles.durationContainer}>
        {durations.map(dur => (
          <TouchableOpacity
            key={dur.value}
            style={[
              styles.durationButton,
              gameState.duration === dur.value && styles.durationButtonSelected,
              gameState.durationLocked && styles.durationButtonDisabled,
            ]}
            onPress={() => {
              if (!gameState.durationLocked) {
                setGameState(prev => ({
                  ...prev,
                  duration: dur.value,
                  timeLeft: dur.value,
                }));
              }
            }}
            disabled={gameState.durationLocked}
          >
            <Text
              style={[
                styles.durationButtonText,
                gameState.duration === dur.value && styles.durationButtonTextSelected,
              ]}
            >
              {dur.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>🎵 Spotify Music Quiz</Text>
          <TouchableOpacity onPress={handleLogout} style={styles.logoutButton}>
            <Text style={styles.logoutText}>Logout</Text>
          </TouchableOpacity>
        </View>

        {/* Score */}
        <View style={styles.scoreContainer}>
          <View style={styles.scoreBox}>
            <Text style={styles.scoreLabel}>Round</Text>
            <Text style={styles.scoreValue}>{gameState.round}</Text>
          </View>
          <View style={styles.scoreBox}>
            <Text style={styles.scoreLabel}>Score</Text>
            <Text style={styles.scoreValue}>{gameState.score}</Text>
          </View>
        </View>

        {/* Playlist Selector */}
        <View style={styles.section}>
          <Text style={styles.sectionLabel}>Select Playlist</Text>
          {renderPlaylistPicker()}
        </View>

        {/* Duration Selector */}
        <View style={styles.section}>
          <Text style={styles.sectionLabel}>Song Duration</Text>
          {renderDurationPicker()}
        </View>

        {/* Timer */}
        <View style={styles.timerContainer}>
          <Text style={styles.timerText}>
            {gameState.duration === 0 ? '∞' : gameState.timeLeft}
          </Text>
          {gameState.duration > 0 && gameState.isPlaying && (
            <View style={styles.timerBar}>
              <View
                style={[
                  styles.timerBarFill,
                  {
                    width: `${(gameState.timeLeft / gameState.duration) * 100}%`,
                  },
                ]}
              />
            </View>
          )}
        </View>

        {/* Song Info */}
        <View style={styles.songInfoContainer}>
          {!gameState.currentTrack && (
            <Text style={styles.songInfoText}>
              Select playlist and duration, then tap "Start Round"!
            </Text>
          )}
          {gameState.isPlaying && !showAnswer && (
            <Text style={styles.songInfoPlaying}>🎵 Song is playing...</Text>
          )}
          {showAnswer && gameState.currentTrack && (
            <View style={styles.answerContainer}>
              <Text style={styles.answerTitle}>
                {gameState.score > (gameState.round - 2) ? '✅ Correct!' : '⏭️ Skipped'}
              </Text>
              <Text style={styles.songName}>{gameState.currentTrack.name}</Text>
              <Text style={styles.artistName}>by {gameState.currentTrack.artists}</Text>
              <Text style={styles.albumInfo}>
                {gameState.currentTrack.album} • {gameState.currentTrack.release_year}
              </Text>
            </View>
          )}
        </View>

        {/* Action Buttons */}
        <View style={styles.buttonContainer}>
          {!gameState.isPlaying ? (
            <TouchableOpacity
              style={[styles.primaryButton, isLoading && styles.primaryButtonDisabled]}
              onPress={startRound}
              disabled={isLoading}
            >
              {isLoading ? (
                <ActivityIndicator color="#FFFFFF" />
              ) : (
                <Text style={styles.primaryButtonText}>
                  {gameState.round === 1 ? 'Start Round' : 'Next Round'}
                </Text>
              )}
            </TouchableOpacity>
          ) : (
            <TouchableOpacity
              style={styles.skipButton}
              onPress={skipRound}
            >
              <Text style={styles.skipButtonText}>Skip (No Points)</Text>
            </TouchableOpacity>
          )}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
  },
  scrollContent: {
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  logoutButton: {
    padding: 8,
  },
  logoutText: {
    color: '#FF6B6B',
    fontSize: 14,
  },
  scoreContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 20,
    marginBottom: 30,
  },
  scoreBox: {
    backgroundColor: '#1E3A1E',
    borderRadius: 10,
    padding: 15,
    minWidth: 100,
    alignItems: 'center',
  },
  scoreLabel: {
    color: '#B3B3B3',
    fontSize: 12,
    marginBottom: 5,
  },
  scoreValue: {
    color: '#FFFFFF',
    fontSize: 32,
    fontWeight: 'bold',
  },
  section: {
    marginBottom: 20,
  },
  sectionLabel: {
    color: '#B3B3B3',
    fontSize: 14,
    marginBottom: 10,
    textAlign: 'center',
  },
  playlistScroll: {
    maxHeight: 50,
  },
  playlistChip: {
    backgroundColor: '#333333',
    borderRadius: 20,
    paddingHorizontal: 15,
    paddingVertical: 8,
    marginRight: 10,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  playlistChipSelected: {
    backgroundColor: '#1E3A1E',
    borderColor: '#1DB954',
  },
  playlistChipDisabled: {
    opacity: 0.5,
  },
  playlistChipText: {
    color: '#B3B3B3',
    fontSize: 14,
  },
  playlistChipTextSelected: {
    color: '#FFFFFF',
    fontWeight: 'bold',
  },
  durationContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 10,
  },
  durationButton: {
    backgroundColor: '#333333',
    borderRadius: 10,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  durationButtonSelected: {
    backgroundColor: '#1E3A1E',
    borderColor: '#1DB954',
  },
  durationButtonDisabled: {
    opacity: 0.5,
  },
  durationButtonText: {
    color: '#B3B3B3',
    fontSize: 14,
    fontWeight: '600',
  },
  durationButtonTextSelected: {
    color: '#FFFFFF',
  },
  timerContainer: {
    alignItems: 'center',
    marginVertical: 30,
  },
  timerText: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginBottom: 10,
  },
  timerBar: {
    width: '100%',
    height: 4,
    backgroundColor: '#333333',
    borderRadius: 2,
    overflow: 'hidden',
  },
  timerBarFill: {
    height: '100%',
    backgroundColor: '#1DB954',
  },
  songInfoContainer: {
    minHeight: 120,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  songInfoText: {
    color: '#B3B3B3',
    fontSize: 14,
    textAlign: 'center',
  },
  songInfoPlaying: {
    color: '#1DB954',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  answerContainer: {
    alignItems: 'center',
  },
  answerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1DB954',
    marginBottom: 10,
  },
  songName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: 5,
  },
  artistName: {
    fontSize: 16,
    color: '#B3B3B3',
    textAlign: 'center',
    marginBottom: 5,
  },
  albumInfo: {
    fontSize: 12,
    color: '#666666',
    textAlign: 'center',
  },
  buttonContainer: {
    marginTop: 20,
  },
  primaryButton: {
    backgroundColor: '#1DB954',
    borderRadius: 25,
    paddingVertical: 15,
    alignItems: 'center',
  },
  primaryButtonDisabled: {
    backgroundColor: '#555555',
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: 'bold',
  },
  skipButton: {
    backgroundColor: '#FFA500',
    borderRadius: 25,
    paddingVertical: 15,
    alignItems: 'center',
  },
  skipButtonText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: 'bold',
  },
});
