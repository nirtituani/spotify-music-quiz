import { Hono } from 'hono'
import { setCookie, getCookie, deleteCookie } from 'hono/cookie'
import { renderer } from './renderer'

type Bindings = {
  SPOTIFY_CLIENT_ID: string
  SPOTIFY_CLIENT_SECRET: string
  SPOTIFY_REDIRECT_URI: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.use(renderer)

// Home page
app.get('/', (c) => {
  const accessToken = getCookie(c, 'spotify_access_token')
  
  return c.render(
    <div class="min-h-screen bg-gradient-to-br from-green-900 via-black to-green-900 text-white">
      <div class="container mx-auto px-4 py-8 max-w-4xl">
        {/* Header */}
        <div class="text-center mb-8">
          <h1 class="text-5xl font-bold mb-4">🎵 Spotify Music Quiz</h1>
          <p class="text-2xl text-green-400 font-semibold">Guess the song in 30 seconds!</p>
        </div>

        {/* Game Status */}
        <div class="flex justify-center gap-8 mb-8">
          <div class="bg-green-800 bg-opacity-50 rounded-lg px-8 py-4">
            <div class="text-gray-300 text-sm">Round</div>
            <div id="round" class="text-3xl font-bold">1</div>
          </div>
          <div class="bg-green-800 bg-opacity-50 rounded-lg px-8 py-4">
            <div class="text-gray-300 text-sm">Score</div>
            <div id="score" class="text-3xl font-bold">0</div>
          </div>
        </div>

        {!accessToken ? (
          // Login Required Section
          <div class="bg-gray-900 bg-opacity-80 rounded-lg p-8 mb-8 border border-green-600">
            <h2 class="text-2xl font-bold mb-4 text-center">🔒 Login Required</h2>
            <p class="text-center mb-6">Please log in with your Spotify Premium account to play</p>
            <div class="text-center">
              <a 
                href="/login" 
                class="inline-block bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-full transition-colors duration-200 text-lg"
              >
                Login with Spotify
              </a>
            </div>
          </div>
        ) : (
          // Game Area
          <div class="bg-gray-900 bg-opacity-80 rounded-lg p-8 mb-8 border border-green-600">
            <div id="game-area">
              {/* Duration Selector */}
              <div class="mb-6">
                <label class="block text-center text-gray-300 text-sm mb-3">Song Duration</label>
                <div class="flex justify-center gap-3">
                  <button 
                    id="duration-30" 
                    class="duration-btn bg-green-700 hover:bg-green-600 text-white font-semibold py-2 px-6 rounded-lg transition-colors duration-200 border-2 border-green-500"
                    data-duration="30"
                  >
                    30 sec
                  </button>
                  <button 
                    id="duration-60" 
                    class="duration-btn bg-gray-700 hover:bg-gray-600 text-white font-semibold py-2 px-6 rounded-lg transition-colors duration-200 border-2 border-transparent"
                    data-duration="60"
                  >
                    60 sec
                  </button>
                  <button 
                    id="duration-full" 
                    class="duration-btn bg-gray-700 hover:bg-gray-600 text-white font-semibold py-2 px-6 rounded-lg transition-colors duration-200 border-2 border-transparent"
                    data-duration="0"
                  >
                    Full Song
                  </button>
                </div>
              </div>

              <div class="text-center mb-6">
                <div id="timer-display" class="text-4xl font-mono mb-4">30</div>
                <div class="w-full bg-gray-700 rounded-full h-2 mb-6">
                  <div id="timer-bar" class="bg-green-500 h-2 rounded-full transition-all duration-1000" style="width: 100%"></div>
                </div>
              </div>
              
              <div id="song-info" class="text-center mb-6 min-h-[60px]">
                <p class="text-gray-400">Click "Start Round" to begin!</p>
              </div>
              
              <div class="flex justify-center gap-4">
                <button 
                  id="start-btn" 
                  class="bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-full transition-colors"
                >
                  Start Round
                </button>
                <button 
                  id="skip-btn" 
                  class="bg-yellow-500 hover:bg-yellow-600 text-white font-bold py-3 px-8 rounded-full transition-colors hidden"
                >
                  Skip (No Points)
                </button>
                <button 
                  id="logout-btn" 
                  class="bg-red-500 hover:bg-red-600 text-white font-bold py-3 px-6 rounded-full transition-colors"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        )}

        {/* How to Play */}
        <div class="bg-gray-900 bg-opacity-80 rounded-lg p-8 border border-green-600">
          <h2 class="text-2xl font-bold mb-4">📖 How to Play</h2>
          <ul class="space-y-3 text-gray-300">
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span>Choose your preferred song duration (30 sec, 60 sec, or Full Song)</span>
            </li>
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span>Listen to a random song from Spotify</span>
            </li>
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span>Wait for the timer to end to earn 1 point and see the answer</span>
            </li>
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span>Skip anytime to see the answer (no points)</span>
            </li>
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span><strong>Requires Spotify Premium account</strong></span>
            </li>
            <li class="flex items-start">
              <span class="text-red-400 mr-2">⚠️</span>
              <span><strong>Desktop/Laptop Only</strong> - Mobile browsers not supported</span>
            </li>
          </ul>
        </div>

        {accessToken && (
          <div class="text-center mt-8">
            <a 
              href="/login" 
              class="text-green-400 hover:text-green-300 underline"
            >
              Not working? Re-login with Spotify
            </a>
          </div>
        )}
      </div>

      {/* Spotify Web Playback SDK */}
      {accessToken && (
        <script src="https://sdk.scdn.co/spotify-player.js"></script>
      )}
      
      <script src="/static/app.js"></script>
    </div>
  )
})

// Login - redirect to Spotify OAuth
app.get('/login', (c) => {
  const clientId = c.env.SPOTIFY_CLIENT_ID || 'YOUR_CLIENT_ID'
  const redirectUri = c.env.SPOTIFY_REDIRECT_URI || 'http://localhost:3000/callback'
  const scope = 'streaming user-read-email user-read-private user-modify-playback-state user-read-playback-state'
  
  const authUrl = `https://accounts.spotify.com/authorize?` +
    `client_id=${clientId}&` +
    `response_type=code&` +
    `redirect_uri=${encodeURIComponent(redirectUri)}&` +
    `scope=${encodeURIComponent(scope)}`
  
  return c.redirect(authUrl)
})

// OAuth callback
app.get('/callback', async (c) => {
  const code = c.req.query('code')
  
  if (!code) {
    return c.text('Error: No authorization code', 400)
  }
  
  const clientId = c.env.SPOTIFY_CLIENT_ID || 'YOUR_CLIENT_ID'
  const clientSecret = c.env.SPOTIFY_CLIENT_SECRET || 'YOUR_CLIENT_SECRET'
  const redirectUri = c.env.SPOTIFY_REDIRECT_URI || 'http://localhost:3000/callback'
  
  try {
    // Exchange code for access token
    const tokenResponse = await fetch('https://accounts.spotify.com/api/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + btoa(`${clientId}:${clientSecret}`)
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirectUri
      })
    })
    
    const data = await tokenResponse.json() as any
    
    if (data.access_token) {
      setCookie(c, 'spotify_access_token', data.access_token, {
        httpOnly: true,
        secure: true,
        maxAge: 3600,
        sameSite: 'Lax'
      })
      
      if (data.refresh_token) {
        setCookie(c, 'spotify_refresh_token', data.refresh_token, {
          httpOnly: true,
          secure: true,
          maxAge: 30 * 24 * 60 * 60,
          sameSite: 'Lax'
        })
      }
      
      return c.redirect('/')
    } else {
      return c.text('Error: Failed to get access token', 400)
    }
  } catch (error) {
    console.error('Error exchanging code:', error)
    return c.text('Error: Failed to authenticate', 500)
  }
})

// Logout
app.get('/logout', (c) => {
  deleteCookie(c, 'spotify_access_token')
  deleteCookie(c, 'spotify_refresh_token')
  return c.redirect('/')
})

// API: Get access token for client-side Spotify SDK
app.get('/api/token', (c) => {
  const accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  return c.json({ access_token: accessToken })
})

// API: Exchange authorization code for token (for mobile app)
app.post('/api/auth/token', async (c) => {
  try {
    const body = await c.req.json() as any
    const { code, redirect_uri } = body
    
    if (!code) {
      return c.json({ error: 'No authorization code provided' }, 400)
    }
    
    const clientId = c.env.SPOTIFY_CLIENT_ID || 'YOUR_CLIENT_ID'
    const clientSecret = c.env.SPOTIFY_CLIENT_SECRET || 'YOUR_CLIENT_SECRET'
    
    console.log('Mobile token exchange:', { redirect_uri, clientId })
    
    // Exchange code for access token
    const tokenResponse = await fetch('https://accounts.spotify.com/api/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + btoa(`${clientId}:${clientSecret}`)
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirect_uri
      })
    })
    
    const data = await tokenResponse.json() as any
    
    if (data.access_token) {
      // Return tokens to mobile app (it will store them in AsyncStorage)
      return c.json({
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_in: data.expires_in
      })
    } else {
      console.error('Spotify token error:', data)
      return c.json({ 
        error: 'Failed to get access token',
        details: data.error_description || data.error 
      }, 400)
    }
  } catch (error) {
    console.error('Error exchanging code:', error)
    return c.json({ error: 'Failed to authenticate', details: String(error) }, 500)
  }
})

// API: Get user's available Spotify devices
app.get('/api/devices', async (c) => {
  const accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  try {
    const devicesResponse = await fetch('https://api.spotify.com/v1/me/player/devices', {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })
    
    const data = await devicesResponse.json() as any
    return c.json(data)
  } catch (error) {
    console.error('Error fetching devices:', error)
    return c.json({ error: 'Failed to fetch devices' }, 500)
  }
})

// API: Play track on specific device or active device
app.post('/api/play', async (c) => {
  const accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  try {
    const body = await c.req.json() as any
    const { uri, device_id } = body
    
    // Build URL - if device_id provided, use it, otherwise play on active device
    const url = device_id 
      ? `https://api.spotify.com/v1/me/player/play?device_id=${device_id}`
      : 'https://api.spotify.com/v1/me/player/play'
    
    const playResponse = await fetch(url, {
      method: 'PUT',
      body: JSON.stringify({ uris: [uri] }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      }
    })
    
    if (playResponse.status === 204 || playResponse.status === 200) {
      return c.json({ success: true })
    } else {
      const errorData = await playResponse.json() as any
      return c.json({ error: errorData.error?.message || 'Failed to play' }, playResponse.status)
    }
  } catch (error) {
    console.error('Error playing track:', error)
    return c.json({ error: 'Failed to play track' }, 500)
  }
})

// API: Get random track
app.get('/api/random-track', async (c) => {
  const accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  try {
    // Search for random tracks using random characters
    const randomSearch = String.fromCharCode(97 + Math.floor(Math.random() * 26)) // random a-z
    const offset = Math.floor(Math.random() * 100)
    
    const searchResponse = await fetch(
      `https://api.spotify.com/v1/search?q=${randomSearch}%25&type=track&limit=50&offset=${offset}`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      }
    )
    
    const data = await searchResponse.json() as any
    
    if (data.tracks && data.tracks.items && data.tracks.items.length > 0) {
      const randomIndex = Math.floor(Math.random() * data.tracks.items.length)
      const track = data.tracks.items[randomIndex]
      
      return c.json({
        id: track.id,
        name: track.name,
        artists: track.artists.map((a: any) => a.name).join(', '),
        uri: track.uri,
        preview_url: track.preview_url
      })
    } else {
      return c.json({ error: 'No tracks found' }, 404)
    }
  } catch (error) {
    console.error('Error fetching random track:', error)
    return c.json({ error: 'Failed to fetch track' }, 500)
  }
})

// API: Get random track (mobile version - accepts Authorization header)
app.get('/api/mobile/random-track', async (c) => {
  const authHeader = c.req.header('Authorization')
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  const accessToken = authHeader.substring(7) // Remove 'Bearer ' prefix
  
  try {
    // Search for random tracks using random characters
    const randomSearch = String.fromCharCode(97 + Math.floor(Math.random() * 26)) // random a-z
    const offset = Math.floor(Math.random() * 100)
    
    const searchResponse = await fetch(
      `https://api.spotify.com/v1/search?q=${randomSearch}%25&type=track&limit=50&offset=${offset}`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      }
    )
    
    const data = await searchResponse.json() as any
    
    if (data.tracks && data.tracks.items && data.tracks.items.length > 0) {
      const randomIndex = Math.floor(Math.random() * data.tracks.items.length)
      const track = data.tracks.items[randomIndex]
      
      return c.json({
        id: track.id,
        name: track.name,
        artists: track.artists.map((a: any) => a.name).join(', '),
        uri: track.uri,
        preview_url: track.preview_url
      })
    } else {
      return c.json({ error: 'No tracks found' }, 404)
    }
  } catch (error) {
    console.error('Error fetching random track:', error)
    return c.json({ error: 'Failed to fetch track', details: String(error) }, 500)
  }
})

export default app
