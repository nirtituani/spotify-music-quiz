// Spotify Music Quiz Game Logic

let gameState = {
  round: 1,
  score: 0,
  isPlaying: false,
  currentTrack: null,
  timer: null,
  timeLeft: 30,
  player: null,
  deviceId: null
};

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
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
  
  // Initialize Spotify Web Playback SDK if logged in
  if (window.Spotify) {
    await initializeSpotifyPlayer();
  }
});

// Initialize Spotify Player
async function initializeSpotifyPlayer() {
  try {
    const tokenResponse = await fetch('/api/token');
    const tokenData = await tokenResponse.json();
    
    if (tokenData.error) {
      console.error('Not authenticated');
      return;
    }
    
    const token = tokenData.access_token;
    
    window.onSpotifyWebPlaybackSDKReady = () => {
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
        showMessage('Spotify Premium required to play music.', 'error');
      });

      player.connect();
    };
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
  
  startBtn.disabled = true;
  startBtn.textContent = 'Loading...';
  
  try {
    // Fetch random track
    const response = await fetch('/api/random-track');
    const track = await response.json();
    
    if (track.error) {
      showMessage('Failed to load track. Please try again.', 'error');
      startBtn.disabled = false;
      startBtn.textContent = 'Start Round';
      return;
    }
    
    gameState.currentTrack = track;
    gameState.isPlaying = true;
    gameState.timeLeft = 30;
    
    // Update UI
    songInfo.innerHTML = '<p class="text-gray-400 animate-pulse">🎵 Song is playing...</p>';
    startBtn.classList.add('hidden');
    skipBtn.classList.remove('hidden');
    
    // Play track
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
    // Fallback: just show message if SDK not ready
    console.warn('Spotify player not ready, using preview mode');
    return;
  }
  
  try {
    const tokenResponse = await fetch('/api/token');
    const tokenData = await tokenResponse.json();
    const token = tokenData.access_token;
    
    await fetch(`https://api.spotify.com/v1/me/player/play?device_id=${gameState.deviceId}`, {
      method: 'PUT',
      body: JSON.stringify({ uris: [uri] }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });
  } catch (error) {
    console.error('Error playing track:', error);
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
  
  gameState.timer = setInterval(() => {
    gameState.timeLeft--;
    timerDisplay.textContent = gameState.timeLeft;
    timerBar.style.width = `${(gameState.timeLeft / 30) * 100}%`;
    
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
    gameState.timeLeft = 30;
    document.getElementById('timer-display').textContent = '30';
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
