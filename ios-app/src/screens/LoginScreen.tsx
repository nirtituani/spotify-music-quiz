import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../types';
import SpotifyAuthService from '../services/SpotifyAuthService';

type LoginScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'Login'
>;

interface Props {
  navigation: LoginScreenNavigationProp;
}

export default function LoginScreen({ navigation }: Props) {
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    setIsLoading(true);
    try {
      const success = await SpotifyAuthService.login();
      
      if (success) {
        navigation.replace('Game');
      } else {
        Alert.alert(
          'Login Failed',
          'Could not log in with Spotify. Please try again.'
        );
      }
    } catch (error) {
      console.error('Login error:', error);
      Alert.alert(
        'Error',
        'An error occurred during login. Please try again.'
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        {/* Logo/Title */}
        <Text style={styles.emoji}>🎵</Text>
        <Text style={styles.title}>Spotify Music Quiz</Text>
        <Text style={styles.subtitle}>Guess the song!</Text>

        {/* Features */}
        <View style={styles.features}>
          <Text style={styles.featureText}>🎸 Choose playlists or decades</Text>
          <Text style={styles.featureText}>⏱️ 30s, 60s, or full song</Text>
          <Text style={styles.featureText}>🏆 Track your score</Text>
          <Text style={styles.featureText}>🎧 Premium account required</Text>
        </View>

        {/* Login Button */}
        <TouchableOpacity
          style={[styles.loginButton, isLoading && styles.loginButtonDisabled]}
          onPress={handleLogin}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <>
              <Text style={styles.loginButtonText}>🎵 Login with Spotify</Text>
            </>
          )}
        </TouchableOpacity>

        {/* Info */}
        <Text style={styles.info}>
          You'll be redirected to Spotify to authorize this app
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emoji: {
    fontSize: 80,
    marginBottom: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 20,
    color: '#1DB954',
    marginBottom: 40,
    textAlign: 'center',
  },
  features: {
    marginBottom: 40,
    alignItems: 'flex-start',
  },
  featureText: {
    fontSize: 16,
    color: '#B3B3B3',
    marginBottom: 10,
  },
  loginButton: {
    backgroundColor: '#1DB954',
    paddingHorizontal: 40,
    paddingVertical: 15,
    borderRadius: 25,
    minWidth: 250,
    alignItems: 'center',
  },
  loginButtonDisabled: {
    backgroundColor: '#555555',
  },
  loginButtonText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: 'bold',
  },
  info: {
    marginTop: 20,
    fontSize: 12,
    color: '#666666',
    textAlign: 'center',
    paddingHorizontal: 40,
  },
});
