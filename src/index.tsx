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

// Test Preview URL availability page
app.get('/test-preview', (c) => {
  return c.html(`<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Preview URL Test</title><style>body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:1200px;margin:0 auto;padding:20px;background:linear-gradient(to bottom right,#1a472a,#000,#1a472a);color:#fff;min-height:100vh}h1{text-align:center;color:#1db954}.button{background:#1db954;color:#fff;border:none;padding:15px 30px;font-size:16px;border-radius:25px;cursor:pointer;display:block;margin:20px auto;font-weight:700}.button:hover{background:#1ed760}.button:disabled{background:#666;cursor:not-allowed}.summary{background:rgba(29,185,84,.2);padding:20px;border-radius:10px;margin-bottom:20px;border:2px solid #1db954}.summary h2{margin-top:0;color:#1db954}.search-result{background:rgba(255,255,255,.05);padding:15px;margin:10px 0;border-radius:8px;border-left:4px solid #1db954}.good{color:#1db954;font-weight:700}.warning{color:#ff9800;font-weight:700}.bad{color:#f44336;font-weight:700}.percentage{font-size:3em;font-weight:700;text-align:center;margin:20px 0}.loading{text-align:center;padding:20px}.spinner{border:4px solid rgba(255,255,255,.1);border-top:4px solid #1db954;border-radius:50%;width:40px;height:40px;animation:spin 1s linear infinite;margin:20px auto}@keyframes spin{0%{transform:rotate(0)}100%{transform:rotate(360deg)}}</style></head><body><h1>🎵 Spotify Preview URL Test</h1><p style="text-align:center;color:#aaa">Test 10 random searches to see what % of tracks have preview URLs</p><div id="loginSection"><p style="text-align:center">Login required</p><button class="button" onclick="location.href='/login'">Login with Spotify</button></div><div id="testSection" style="display:none"><button id="testButton" class="button" onclick="runTest()">Run Test</button><div id="status"></div><div id="results"></div></div><script>async function checkAuth(){try{const r=await fetch('/api/user/playlists');if(r.ok){document.getElementById('loginSection').style.display='none';document.getElementById('testSection').style.display='block'}}catch(e){}}async function runTest(){const btn=document.getElementById('testButton'),st=document.getElementById('status'),res=document.getElementById('results');btn.disabled=true;st.innerHTML='<div class="loading"><div class="spinner"></div><p>Testing...</p></div>';res.innerHTML='';try{const d={totalSearches:10,searchResults:[],summary:{totalTracks:0,tracksWithPreview:0,tracksWithoutPreview:0,percentageWithPreview:0}};for(let i=0;i<10;i++){st.innerHTML=\`<div class="loading"><div class="spinner"></div><p>Search \${i+1}/10</p></div>\`;const c=String.fromCharCode(97+Math.floor(Math.random()*26)),o=Math.floor(Math.random()*100),r=await fetch(\`https://api.spotify.com/v1/search?q=\${c}%25&type=track&limit=50&offset=\${o}\`,{headers:{'Authorization':'Bearer '+await getToken()}});const data=await r.json();if(data.tracks?.items?.length>0){const t=data.tracks.items,w=t.filter(x=>x.preview_url),wo=t.filter(x=>!x.preview_url);d.searchResults.push({searchQuery:\`\${c}%\`,offset:o,totalTracks:t.length,withPreview:w.length,withoutPreview:wo.length,percentageWithPreview:Math.round(w.length/t.length*100),sampleWithPreview:w.slice(0,3).map(x=>({name:x.name,artists:x.artists.map(a=>a.name).join(', ')})),sampleWithoutPreview:wo.slice(0,3).map(x=>({name:x.name,artists:x.artists.map(a=>a.name).join(', ')}))});d.summary.totalTracks+=t.length;d.summary.tracksWithPreview+=w.length;d.summary.tracksWithoutPreview+=wo.length}}d.summary.percentageWithPreview=Math.round(d.summary.tracksWithPreview/d.summary.totalTracks*100);showResults(d)}catch(e){st.innerHTML=\`<div class="bad">Error: \${e.message}</div>\`}finally{btn.disabled=false}}function showResults(d){const st=document.getElementById('status'),res=document.getElementById('results'),p=d.summary.percentageWithPreview;let cls='good',emoji='✅',msg='Excellent!';if(p<30){cls='bad';emoji='❌';msg='Too few preview URLs'}else if(p<50){cls='warning';emoji='⚠️';msg='May have issues'}else if(p<70){cls='warning';emoji='⚠️';msg='Most tracks OK'}st.innerHTML='';res.innerHTML=\`<div class="summary"><h2>\${emoji} Results</h2><div class="percentage \${cls}">\${p}%</div><p style="text-align:center;font-size:1.2em">\${msg}</p><hr style="border-color:rgba(255,255,255,.2);margin:20px 0"><p><strong>Total:</strong> \${d.summary.totalTracks}</p><p><strong>With Preview:</strong> <span class="good">\${d.summary.tracksWithPreview}</span></p><p><strong>Without:</strong> <span class="bad">\${d.summary.tracksWithoutPreview}</span></p></div><h3>Details</h3>\${d.searchResults.map((r,i)=>\`<div class="search-result"><h4>Search \${i+1}: "\${r.searchQuery}" (offset:\${r.offset})</h4><p>Total:\${r.totalTracks} | With:<span class="good">\${r.withPreview}</span>(\${r.percentageWithPreview}%) | Without:<span class="bad">\${r.withoutPreview}</span></p></div>\`).join('')}\`}async function getToken(){const c=document.cookie.split(';');for(let x of c){const[n,v]=x.trim().split('=');if(n==='spotify_access_token')return decodeURIComponent(v)}throw new Error('Not auth')}checkAuth()</script></body></html>`)
})

// API endpoint to test preview URL availability (backend version)
app.get('/api/test-preview-stats', async (c) => {
  const accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  try {
    const stats = { total: 0, withPreview: 0, percentage: 0 }
    
    for (let i = 0; i < 10; i++) {
      const randomChar = String.fromCharCode(97 + Math.floor(Math.random() * 26))
      const offset = Math.floor(Math.random() * 100)
      
      const response = await fetch(
        `https://api.spotify.com/v1/search?q=${randomChar}%25&type=track&limit=50&offset=${offset}`,
        { headers: { 'Authorization': `Bearer ${accessToken}` } }
      )
      
      const data = await response.json() as any
      
      if (data.tracks?.items) {
        stats.total += data.tracks.items.length
        stats.withPreview += data.tracks.items.filter((t: any) => t.preview_url).length
      }
    }
    
    stats.percentage = Math.round((stats.withPreview / stats.total) * 100)
    return c.json(stats)
  } catch (error) {
    return c.json({ error: 'Test failed', details: String(error) }, 500)
  }
})

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
              {/* Playlist Selector */}
              <div class="mb-6">
                <label class="block text-center text-gray-300 text-sm mb-3">Select Playlist</label>
                <div class="flex justify-center">
                  <select 
                    id="playlist-selector"
                    class="bg-gray-700 text-white px-6 py-2 rounded-lg border-2 border-green-500 focus:outline-none focus:border-green-400 cursor-pointer"
                  >
                    <option value="random">🎲 Random from Spotify</option>
                    <option value="loading" disabled>Loading playlists...</option>
                  </select>
                </div>
              </div>

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
              <span>Choose a playlist (or use Random from Spotify)</span>
            </li>
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span>Choose your preferred song duration (30 sec, 60 sec, or Full Song)</span>
            </li>
            <li class="flex items-start">
              <span class="text-green-500 mr-2">•</span>
              <span>Listen to a random song from your selected source</span>
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
  const scope = 'streaming user-read-email user-read-private user-modify-playback-state user-read-playback-state playlist-read-private playlist-read-collaborative'
  
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

// API: Get user's playlists
app.get('/api/playlists', async (c) => {
  // Support both cookie (web) and Authorization header (mobile)
  let accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    const authHeader = c.req.header('Authorization')
    if (authHeader && authHeader.startsWith('Bearer ')) {
      accessToken = authHeader.substring(7)
    }
  }
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  try {
    const playlistsResponse = await fetch(
      'https://api.spotify.com/v1/me/playlists?limit=50',
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      }
    )
    
    const data = await playlistsResponse.json() as any
    
    if (data.items) {
      const playlists = data.items.map((playlist: any) => ({
        id: playlist.id,
        name: playlist.name,
        tracks_total: playlist.tracks.total,
        images: playlist.images
      }))
      
      return c.json({ playlists })
    } else {
      return c.json({ error: 'No playlists found' }, 404)
    }
  } catch (error) {
    console.error('Error fetching playlists:', error)
    return c.json({ error: 'Failed to fetch playlists' }, 500)
  }
})

// API: Get random track
app.get('/api/random-track', async (c) => {
  // Support both cookie (web) and Authorization header (mobile)
  let accessToken = getCookie(c, 'spotify_access_token')
  
  if (!accessToken) {
    const authHeader = c.req.header('Authorization')
    if (authHeader && authHeader.startsWith('Bearer ')) {
      accessToken = authHeader.substring(7)
    }
  }
  
  if (!accessToken) {
    return c.json({ error: 'Not authenticated' }, 401)
  }
  
  const playlistId = c.req.query('playlist_id')
  
  try {
    let track;
    
    if (playlistId && playlistId.startsWith('genre:')) {
      // Genre-based search (curated playlists)
      const genreKey = playlistId.replace('genre:', '');
      
      // Map genre keys to search queries
      const genreQueries: { [key: string]: string } = {
        // Decades
        '60s': 'year:1960-1969',
        '70s': 'year:1970-1979',
        '80s': 'year:1980-1989',
        '90s': 'year:1990-1999',
        '00s': 'year:2000-2009',
        '10s': 'year:2010-2019',
        '20s': 'year:2020-2029',
        // Genres
        'rock': 'genre:rock',
        'pop': 'genre:pop',
        'hip-hop': 'genre:"hip hop"',
        'electronic': 'genre:electronic',
        'jazz': 'genre:jazz',
        'classical': 'genre:classical',
        'country': 'genre:country',
        'r&b': 'genre:r&b',
        'metal': 'genre:metal',
        'indie': 'genre:indie',
        // Themes
        'soundtrack': 'genre:soundtrack',
        'disney': 'disney',
        'workout': 'workout',
        'chill': 'chill',
        'party': 'party',
        'sad': 'sad',
        // Regional - using tag:hipster to get more diverse/popular results
        'israeli': 'tag:hipster hebrew',
        'latin': 'genre:latin',
        'k-pop': 'genre:k-pop',
        'french': 'genre:french',
        'arabic': 'genre:arabic'
      };
      
      let searchUrl;
      
      if (genreKey === 'israeli') {
        // Special handling for Israeli music - search for popular Israeli artists
        const israeliArtists = [
          'Omer Adam', 'Static and Ben El', 'Netta', 'Sarit Hadad', 
          'Eyal Golan', 'Mizrahi', 'Ivri Lider', 'Teapacks', 
          'Infected Mushroom', 'Subliminal', 'Mosh Ben Ari', 'Berry Sakharof',
          'Ehud Banai', 'Shlomo Artzi', 'Ofra Haza', 'Arik Einstein',
          'Shalom Hanoch', 'Yasmin Levy', 'Eden Ben Zaken', 'Noa Kirel'
        ];
        const randomArtist = israeliArtists[Math.floor(Math.random() * israeliArtists.length)];
        searchUrl = `https://api.spotify.com/v1/search?q=${encodeURIComponent(randomArtist)}&type=track&limit=50`;
      } else {
        const searchQuery = genreQueries[genreKey] || genreKey;
        const randomChar = String.fromCharCode(97 + Math.floor(Math.random() * 26)); // a-z
        const offset = Math.floor(Math.random() * 100);
        searchUrl = `https://api.spotify.com/v1/search?q=${encodeURIComponent(searchQuery)}%20${randomChar}&type=track&limit=50&offset=${offset}`;
      }
      
      const searchResponse = await fetch(searchUrl, {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      })
      
      const data = await searchResponse.json() as any
      
      if (data.tracks && data.tracks.items && data.tracks.items.length > 0) {
        // Filter to only tracks WITH preview URLs (needed for mobile playback)
        const tracksWithPreview = data.tracks.items.filter((t: any) => t.preview_url)
        
        if (tracksWithPreview.length > 0) {
          const randomIndex = Math.floor(Math.random() * tracksWithPreview.length)
          track = tracksWithPreview[randomIndex]
        } else {
          // Fallback: use any track if none have previews
          const randomIndex = Math.floor(Math.random() * data.tracks.items.length)
          track = data.tracks.items[randomIndex]
        }
      } else {
        return c.json({ error: 'No tracks found for this genre' }, 404)
      }
    } else if (playlistId && playlistId !== 'random') {
      // Get random track from specific user playlist
      const playlistResponse = await fetch(
        `https://api.spotify.com/v1/playlists/${playlistId}/tracks?limit=100`,
        {
          headers: {
            'Authorization': `Bearer ${accessToken}`
          }
        }
      )
      
      const playlistData = await playlistResponse.json() as any
      
      if (playlistData.items && playlistData.items.length > 0) {
        // Filter to only tracks WITH preview URLs (needed for mobile playback)
        const tracksWithPreview = playlistData.items.filter((item: any) => item.track && item.track.preview_url)
        
        if (tracksWithPreview.length > 0) {
          const randomIndex = Math.floor(Math.random() * tracksWithPreview.length)
          track = tracksWithPreview[randomIndex].track
        } else {
          // Fallback: use any track if none have previews
          const randomIndex = Math.floor(Math.random() * playlistData.items.length)
          track = playlistData.items[randomIndex].track
        }
      } else {
        return c.json({ error: 'No tracks found in playlist' }, 404)
      }
    } else {
      // Search for random tracks using random characters (default "Random from Spotify")
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
        // Filter to only tracks WITH preview URLs (needed for mobile playback)
        const tracksWithPreview = data.tracks.items.filter((t: any) => t.preview_url)
        
        if (tracksWithPreview.length > 0) {
          const randomIndex = Math.floor(Math.random() * tracksWithPreview.length)
          track = tracksWithPreview[randomIndex]
        } else {
          // Fallback: use any track if none have previews
          const randomIndex = Math.floor(Math.random() * data.tracks.items.length)
          track = data.tracks.items[randomIndex]
        }
      } else {
        return c.json({ error: 'No tracks found' }, 404)
      }
    }
    
    if (track) {
      // Fetch full track details to get accurate release date
      let releaseYear = 'Unknown';
      let albumName = 'Unknown Album';
      
      try {
        const trackDetailsResponse = await fetch(
          `https://api.spotify.com/v1/tracks/${track.id}`,
          {
            headers: {
              'Authorization': `Bearer ${accessToken}`
            }
          }
        )
        
        const trackDetails = await trackDetailsResponse.json() as any
        
        // Get the album release date (this is the song's original release year)
        if (trackDetails.album && trackDetails.album.release_date) {
          releaseYear = trackDetails.album.release_date.split('-')[0]; // Get YYYY part
        }
        
        if (trackDetails.album && trackDetails.album.name) {
          albumName = trackDetails.album.name;
        }
      } catch (error) {
        console.error('Error fetching track details:', error);
        // Fallback to basic info
        if (track.album && track.album.release_date) {
          releaseYear = track.album.release_date.split('-')[0];
        }
        if (track.album && track.album.name) {
          albumName = track.album.name;
        }
      }
      
      return c.json({
        id: track.id,
        name: track.name,
        artists: track.artists.map((a: any) => a.name).join(', '),
        uri: track.uri,
        preview_url: track.preview_url,
        release_year: releaseYear,
        album: albumName
      })
    } else {
      return c.json({ error: 'No track found' }, 404)
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
