// Spotify Music Quiz Game Logic

let gameState = {
  round: 1,
  score: 0,
  isPlaying: false,
  currentTrack: null,
  timer: null,
  timeLeft: 30,
  duration: 30,
  durationLocked: false, // Lock duration after first round starts
  playlistId: 'random', // Selected playlist ID ('random' = default)
  playlistLocked: false, // Lock playlist after first round starts
  player: null,
  deviceId: null,
  isMobile: false
};

// Define Spotify Web Playback SDK callback EARLY (before SDK loads)
window.onSpotifyWebPlaybackSDKReady = () => {
  console.log('Spotify SDK Ready - callback fired');
  // The actual initialization will happen in initializeSpotifyPlayer()
  if (window.spotifyPlayerInitializer) {
    window.spotifyPlayerInitializer();
  }
};

// Detect if mobile device
function isMobileDevice() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
         (window.innerWidth <= 768);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
  // Detect mobile
  gameState.isMobile = isMobileDevice();
  console.log('Mobile device detected:', gameState.isMobile);
  
  // Show mobile warning if on mobile
  if (gameState.isMobile) {
    showMobileWarning();
    return; // Don't initialize game on mobile
  }
  
  const startBtn = document.getElementById('start-btn');
  const skipBtn = document.getElementById('skip-btn');
  const logoutBtn = document.getElementById('logout-btn');
  
  if (startBtn) {
    startBtn.addEventListener('click', startRound);
  }
  
  if (skipBtn) {
    skipBtn.addEventListener('click', skipRound);
  }
  
  if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {
      window.location.href = '/logout';
    });
  }
  
  // Duration selector buttons
  const durationBtns = document.querySelectorAll('.duration-btn');
  durationBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      // Don't allow changes if duration is locked (game has started)
      if (gameState.durationLocked) {
        return;
      }
      
      // Update active state
      durationBtns.forEach(b => {
        b.classList.remove('bg-green-700', 'border-green-500');
        b.classList.add('bg-gray-700', 'border-transparent');
      });
      btn.classList.remove('bg-gray-700', 'border-transparent');
      btn.classList.add('bg-green-700', 'border-green-500');
      
      // Update game state
      gameState.duration = parseInt(btn.dataset.duration);
      gameState.timeLeft = gameState.duration;
      
      // Update timer display
      const timerDisplay = document.getElementById('timer-display');
      if (timerDisplay) {
        timerDisplay.textContent = gameState.duration === 0 ? '∞' : gameState.duration;
      }
      
      console.log('Duration changed to:', gameState.duration === 0 ? 'Full Song' : `${gameState.duration} seconds`);
    });
  });
  
  // Playlist selector
  const playlistSelector = document.getElementById('playlist-selector');
  if (playlistSelector) {
    // Load user's playlists
    loadPlaylists();
    
    // Handle playlist selection
    playlistSelector.addEventListener('change', (e) => {
      if (gameState.playlistLocked) {
        // Reset to current selection if locked
        e.target.value = gameState.playlistId;
        return;
      }
      
      gameState.playlistId = e.target.value;
      console.log('Playlist changed to:', gameState.playlistId);
    });
  }
  
  // Prepare for Spotify SDK initialization (will be called by SDK callback)
  initializeSpotifyPlayer();
});

// Load user's playlists from Spotify
async function loadPlaylists() {
  try {
    const response = await fetch('/api/playlists');
    const data = await response.json();
    
    const playlistSelector = document.getElementById('playlist-selector');
    if (!playlistSelector) return;
    
    if (data.playlists && data.playlists.length > 0) {
      // Remove loading option
      playlistSelector.innerHTML = '<option value="random">🎲 Random from Spotify</option>';
      
      // Add user's playlists
      data.playlists.forEach(playlist => {
        const option = document.createElement('option');
        option.value = playlist.id;
        option.textContent = `${playlist.name} (${playlist.tracks_total} songs)`;
        playlistSelector.appendChild(option);
      });
      
      console.log('Loaded', data.playlists.length, 'playlists');
    } else {
      playlistSelector.innerHTML = '<option value="random">🎲 Random from Spotify</option>';
      console.log('No playlists found');
    }
  } catch (error) {
    console.error('Error loading playlists:', error);
    const playlistSelector = document.getElementById('playlist-selector');
    if (playlistSelector) {
      playlistSelector.innerHTML = '<option value="random">🎲 Random from Spotify</option>';
    }
  }
}

// Lock playlist selector (disable it visually and functionally)
function lockPlaylistSelector() {
  const playlistSelector = document.getElementById('playlist-selector');
  if (playlistSelector) {
    playlistSelector.disabled = true;
    playlistSelector.classList.add('opacity-50', 'cursor-not-allowed');
  }
  console.log('Playlist locked at:', gameState.playlistId === 'random' ? 'Random from Spotify' : gameState.playlistId);
}

// Lock duration buttons (disable them visually and functionally)
function lockDurationButtons() {
  const durationBtns = document.querySelectorAll('.duration-btn');
  durationBtns.forEach(btn => {
    btn.disabled = true;
    btn.classList.add('opacity-50', 'cursor-not-allowed');
    btn.classList.remove('hover:bg-green-600', 'hover:bg-gray-600');
  });
  console.log('Duration locked at:', gameState.duration === 0 ? 'Full Song' : `${gameState.duration} seconds`);
}

// Show mobile warning
function showMobileWarning() {
  const gameArea = document.getElementById('game-area');
  if (gameArea) {
    gameArea.innerHTML = `
      <div class="text-center">
        <div class="text-6xl mb-4">📱</div>
        <h3 class="text-2xl font-bold mb-4 text-yellow-400">Desktop Required</h3>
        <p class="text-gray-300 mb-4">
          This quiz requires a <strong>desktop or laptop computer</strong> with Spotify Premium.
        </p>
        <p class="text-gray-400 text-sm mb-4">
          Mobile browsers don't support Spotify playback without revealing the song name, 
          which would ruin the quiz experience.
        </p>
        <p class="text-green-400 font-semibold">
          Please open this page on a desktop or laptop to play! 🖥️
        </p>
      </div>
    `;
  }
}

// Initialize Spotify Player (Desktop only)
async function initializeSpotifyPlayer() {
  try {
    const tokenResponse = await fetch('/api/token');
    const tokenData = await tokenResponse.json();
    
    if (tokenData.error) {
      console.error('Not authenticated');
      return;
    }
    
    const token = tokenData.access_token;
    
    // Define the player initializer function
    window.spotifyPlayerInitializer = () => {
      console.log('Initializing Spotify Player with token');
      const player = new Spotify.Player({
        name: 'Spotify Music Quiz',
        getOAuthToken: cb => { cb(token); },
        volume: 0.5
      });

      // Ready
      player.addListener('ready', ({ device_id }) => {
        console.log('Ready with Device ID', device_id);
        gameState.deviceId = device_id;
        gameState.player = player;
      });

      // Not Ready
      player.addListener('not_ready', ({ device_id }) => {
        console.log('Device ID has gone offline', device_id);
      });

      player.addListener('initialization_error', ({ message }) => {
        console.error('Initialization Error:', message);
      });

      player.addListener('authentication_error', ({ message }) => {
        console.error('Authentication Error:', message);
        showMessage('Authentication failed. Please re-login.', 'error');
      });

      player.addListener('account_error', ({ message }) => {
        console.error('Account Error:', message);
        showMessage('Spotify Premium required to play music. Please upgrade your account.', 'error');
      });

      player.connect();
    };
    
    // If Spotify SDK already loaded, initialize immediately
    if (window.Spotify) {
      console.log('Spotify SDK already loaded, initializing now');
      window.spotifyPlayerInitializer();
    }
  } catch (error) {
    console.error('Failed to initialize player:', error);
  }
}

// Start a new round
async function startRound() {
  if (gameState.isPlaying) return;
  
  const startBtn = document.getElementById('start-btn');
  const skipBtn = document.getElementById('skip-btn');
  const songInfo = document.getElementById('song-info');
  
  if (!gameState.deviceId) {
    showMessage('Waiting for Spotify player to connect... Please wait a moment and try again.', 'error');
    return;
  }
  
  startBtn.disabled = true;
  startBtn.textContent = 'Loading...';
  
  // Lock duration and playlist after first round starts
  if (!gameState.durationLocked) {
    gameState.durationLocked = true;
    lockDurationButtons();
  }
  
  if (!gameState.playlistLocked) {
    gameState.playlistLocked = true;
    lockPlaylistSelector();
  }
  
  try {
    // Fetch random track from selected playlist
    const url = gameState.playlistId === 'random' 
      ? '/api/random-track' 
      : `/api/random-track?playlist_id=${gameState.playlistId}`;
    const response = await fetch(url);
    const track = await response.json();
    
    if (track.error) {
      showMessage('Failed to load track. Please try again.', 'error');
      startBtn.disabled = false;
      startBtn.textContent = 'Start Round';
      return;
    }
    
    gameState.currentTrack = track;
    gameState.isPlaying = true;
    gameState.timeLeft = gameState.duration;
    
    // Update UI
    songInfo.innerHTML = '<p class="text-gray-400 animate-pulse">🎵 Song is playing...</p>';
    startBtn.classList.add('hidden');
    skipBtn.classList.remove('hidden');
    
    // Play track using Web Playback SDK
    await playTrack(track.uri);
    
    // Start timer
    startTimer();
    
  } catch (error) {
    console.error('Error starting round:', error);
    showMessage('Error starting round. Please try again.', 'error');
    startBtn.disabled = false;
    startBtn.textContent = 'Start Round';
  }
}

// Play track using Spotify Web Playback SDK
async function playTrack(uri) {
  if (!gameState.deviceId) {
    showMessage('Spotify player not ready. Please refresh the page.', 'error');
    return;
  }
  
  try {
    const tokenResponse = await fetch('/api/token');
    const tokenData = await tokenResponse.json();
    const token = tokenData.access_token;
    
    const response = await fetch(`https://api.spotify.com/v1/me/player/play?device_id=${gameState.deviceId}`, {
      method: 'PUT',
      body: JSON.stringify({ uris: [uri] }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      console.error('Playback error:', errorData);
      
      if (errorData.error?.reason === 'PREMIUM_REQUIRED') {
        showMessage('Spotify Premium is required to play music. Please upgrade your account.', 'error');
      } else {
        showMessage('Failed to play track. Please try again.', 'error');
      }
    }
  } catch (error) {
    console.error('Error playing track:', error);
    showMessage('Error playing track. Please try again.', 'error');
  }
}

// Stop playback
async function stopPlayback() {
  if (gameState.player) {
    gameState.player.pause();
  }
}

// Start timer
function startTimer() {
  const timerDisplay = document.getElementById('timer-display');
  const timerBar = document.getElementById('timer-bar');
  
  // Full song mode - no countdown
  if (gameState.duration === 0) {
    timerDisplay.textContent = '∞';
    timerBar.style.width = '100%';
    return; // No timer in full song mode
  }
  
  // Normal countdown mode
  gameState.timer = setInterval(() => {
    gameState.timeLeft--;
    timerDisplay.textContent = gameState.timeLeft;
    timerBar.style.width = `${(gameState.timeLeft / gameState.duration) * 100}%`;
    
    if (gameState.timeLeft <= 0) {
      clearInterval(gameState.timer);
      endRound(true); // Timer ended, give point
    }
  }, 1000);
}

// Skip round
function skipRound() {
  clearInterval(gameState.timer);
  endRound(false); // Skipped, no point
}

// End round
async function endRound(earnedPoint) {
  gameState.isPlaying = false;
  
  const startBtn = document.getElementById('start-btn');
  const skipBtn = document.getElementById('skip-btn');
  const songInfo = document.getElementById('song-info');
  const scoreEl = document.getElementById('score');
  const roundEl = document.getElementById('round');
  
  // Stop playback
  await stopPlayback();
  
  // Update score
  if (earnedPoint) {
    gameState.score++;
    scoreEl.textContent = gameState.score;
  }
  
  // Show answer
  const track = gameState.currentTrack;
  songInfo.innerHTML = `
    <div class="text-center">
      <p class="text-xl mb-2">${earnedPoint ? '✅ Round Complete! +1 Point' : '⏭️ Skipped - No Points'}</p>
      <p class="text-2xl font-bold text-green-400">${track.name}</p>
      <p class="text-lg text-gray-300">by ${track.artists}</p>
    </div>
  `;
  
  // Update round
  gameState.round++;
  roundEl.textContent = gameState.round;
  
  // Reset UI for next round
  skipBtn.classList.add('hidden');
  startBtn.classList.remove('hidden');
  startBtn.disabled = false;
  startBtn.textContent = 'Next Round';
  
  // Reset timer display
  setTimeout(() => {
    gameState.timeLeft = gameState.duration;
    const timerDisplay = document.getElementById('timer-display');
    timerDisplay.textContent = gameState.duration === 0 ? '∞' : gameState.duration;
    document.getElementById('timer-bar').style.width = '100%';
  }, 100);
}

// Show message
function showMessage(message, type = 'info') {
  const songInfo = document.getElementById('song-info');
  if (songInfo) {
    const color = type === 'error' ? 'text-red-400' : 'text-yellow-400';
    songInfo.innerHTML = `<p class="${color}">${message}</p>`;
  }
}
