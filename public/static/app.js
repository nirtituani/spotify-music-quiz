// Spotify Music Quiz Game Logic

let gameState = {
  round: 1,
  score: 0,
  isPlaying: false,
  currentTrack: null,
  timer: null,
  timeLeft: 30,
  player: null,
  deviceId: null,
  userDevices: [],
  isMobile: false
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
  
  // Check for available Spotify devices (including mobile app)
  await checkUserDevices();
  
  // Initialize Spotify Web Playback SDK ONLY on desktop
  if (!gameState.isMobile && window.Spotify) {
    await initializeSpotifyPlayer();
  } else {
    console.log('Mobile mode: Will use Spotify app or active device for playback');
  }
});

// Check user's available Spotify devices
async function checkUserDevices() {
  try {
    const response = await fetch('/api/devices');
    const data = await response.json();
    
    if (data.devices) {
      gameState.userDevices = data.devices;
      console.log('Available Spotify devices:', gameState.userDevices);
      
      // Check if user has an active device
      const activeDevice = data.devices.find(d => d.is_active);
      if (activeDevice) {
        console.log('Active device found:', activeDevice.name, activeDevice.type);
      } else if (data.devices.length > 0) {
        console.log('Devices available but none active. Will attempt to play on first available device.');
      } else {
        console.log('No Spotify devices found. User needs to open Spotify app.');
      }
    }
  } catch (error) {
    console.error('Error checking devices:', error);
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
    const playSuccess = await playTrack(track);
    
    if (!playSuccess) {
      showMessage('⚠️ Please open Spotify app on your device and start playing any song, then try again.', 'error');
      startBtn.disabled = false;
      startBtn.classList.remove('hidden');
      skipBtn.classList.add('hidden');
      gameState.isPlaying = false;
      return;
    }
    
    // Start timer
    startTimer();
    
  } catch (error) {
    console.error('Error starting round:', error);
    showMessage('Error starting round. Please try again.', 'error');
    startBtn.disabled = false;
    startBtn.textContent = 'Start Round';
  }
}

// Play track - handles both mobile and desktop
async function playTrack(track) {
  // Desktop: Use Spotify Web Playback SDK
  if (!gameState.isMobile && gameState.deviceId) {
    try {
      const response = await fetch('/api/play', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          uri: track.uri,
          device_id: gameState.deviceId
        })
      });
      
      const result = await response.json();
      
      if (result.success) {
        console.log('Playing via Web Playback SDK on desktop');
        return true;
      } else {
        console.error('Play failed:', result.error);
        return false;
      }
    } catch (error) {
      console.error('Error playing track:', error);
      return false;
    }
  }
  
  // Mobile: Play on user's active Spotify device (their phone's Spotify app)
  try {
    // Refresh device list
    await checkUserDevices();
    
    // Try to find active device or use first available
    let targetDevice = gameState.userDevices.find(d => d.is_active);
    
    if (!targetDevice && gameState.userDevices.length > 0) {
      // No active device, but devices exist - use first available
      targetDevice = gameState.userDevices[0];
      console.log('No active device, attempting to use:', targetDevice.name);
    }
    
    if (!targetDevice) {
      // No devices available at all
      console.error('No Spotify devices available');
      return false;
    }
    
    const response = await fetch('/api/play', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        uri: track.uri,
        device_id: targetDevice.id
      })
    });
    
    const result = await response.json();
    
    if (result.success) {
      console.log('Playing on Spotify device:', targetDevice.name, targetDevice.type);
      return true;
    } else {
      console.error('Play failed:', result.error);
      
      // Common error: Device needs to be active first
      if (result.error && result.error.includes('No active device')) {
        console.log('No active device - user needs to open Spotify app');
      }
      
      return false;
    }
  } catch (error) {
    console.error('Error playing track on mobile:', error);
    return false;
  }
}

// Stop playback
async function stopPlayback() {
  // Desktop: Stop Web Playback SDK player
  if (gameState.player) {
    try {
      await gameState.player.pause();
      console.log('Paused Web Playback SDK player');
    } catch (error) {
      console.error('Error pausing player:', error);
    }
  }
  
  // Mobile: Pause via API (will pause user's Spotify app)
  if (gameState.isMobile) {
    try {
      const tokenResponse = await fetch('/api/token');
      const tokenData = await tokenResponse.json();
      
      if (tokenData.access_token) {
        await fetch('https://api.spotify.com/v1/me/player/pause', {
          method: 'PUT',
          headers: {
            'Authorization': `Bearer ${tokenData.access_token}`
          }
        });
        console.log('Paused Spotify app playback');
      }
    } catch (error) {
      console.error('Error pausing mobile playback:', error);
    }
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
  const modeIndicator = gameState.isMobile ? '📱 Mobile Mode (Premium)' : '🖥️ Desktop Mode';
  songInfo.innerHTML = `
    <div class="text-center">
      <p class="text-sm text-gray-500 mb-1">${modeIndicator}</p>
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
