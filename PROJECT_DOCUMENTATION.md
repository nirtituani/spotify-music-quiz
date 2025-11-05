# 🎵 Spotify Music Quiz - Project Documentation

> **Version**: 1.1.0  
> **Last Updated**: 2025-11-05  
> **Status**: ✅ Fully Functional  
> **Production URL**: https://spotify-music-quiz.pages.dev/  
> **GitHub**: https://github.com/nirtituani/spotify-music-quiz

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Game Mechanics](#game-mechanics)
3. [Architecture](#architecture)
4. [File Structure](#file-structure)
5. [Key Components](#key-components)
6. [API Endpoints](#api-endpoints)
7. [Data Flow](#data-flow)
8. [Deployment](#deployment)
9. [Common Issues & Solutions](#common-issues--solutions)
10. [Future Development](#future-development)

---

## 🎮 Project Overview

### What is Spotify Music Quiz?

A web-based music quiz game that plays random songs from Spotify and challenges users to identify them. The game uses Spotify's Web Playback SDK to stream full-quality audio without revealing song information, maintaining the quiz challenge.

### Key Features

- **Song Duration Selector**: Choose between 30 seconds, 60 seconds, or Full Song playback
- **Duration Locking**: Once game starts, duration is locked for all rounds
- **Spotify Premium Integration**: Full song playback using Web Playback SDK
- **Round-based Scoring**: Earn points by listening to the full duration
- **Skip Functionality**: Skip songs without earning points
- **Desktop-only Mode**: Mobile browsers show informative warning

### Technical Highlights

- **Platform**: Cloudflare Pages (Edge Computing)
- **Backend**: Hono Framework (TypeScript)
- **Frontend**: Vanilla JavaScript + Tailwind CSS (CDN)
- **Authentication**: OAuth 2.0 with secure HTTP-only cookies
- **No Database**: Stateless game, all state stored client-side

---

## 🎮 Game Mechanics

### How to Play

1. **Login**: User authenticates with Spotify Premium account
2. **Select Duration**: Before starting, choose song duration (30s, 60s, or Full Song)
3. **Start Round**: Click "Start Round" to play a random song
4. **Listen**: Song plays through Spotify Web Playback SDK
5. **Wait or Skip**: 
   - Wait for timer to reach 0 → Earn 1 point + see answer
   - Click "Skip" → See answer immediately but no points
6. **Next Round**: Click "Next Round" to continue with same duration
7. **Score**: Accumulate points across unlimited rounds

### Duration Selector Behavior

- **Before First Round**: All three buttons are clickable and highlighted
- **After Start Round**: Buttons become disabled (grayed out, unclickable)
- **Locked for Session**: Same duration applies to ALL subsequent rounds
- **Full Song Mode**: Timer shows ∞ symbol, no countdown, music plays until manually skipped

### Scoring System

- **Wait for Timer**: +1 point
- **Skip Early**: 0 points
- **No Penalty**: Skipping doesn't reduce score
- **Unlimited Rounds**: Play as long as you want

---

## 🏗️ Architecture

### Technology Stack

```
┌─────────────────────────────────────┐
│     Cloudflare Pages (Edge)         │
├─────────────────────────────────────┤
│  Hono Framework (TypeScript)        │
│  - Server-side rendering (JSX)      │
│  - API routes                       │
│  - OAuth flow                       │
│  - Cookie management                │
└─────────────────────────────────────┘
            ↕ HTTPS
┌─────────────────────────────────────┐
│     Browser (Desktop Only)          │
├─────────────────────────────────────┤
│  HTML (JSX-rendered)                │
│  Vanilla JavaScript (app.js)        │
│  Tailwind CSS (CDN)                 │
│  Spotify Web Playback SDK           │
└─────────────────────────────────────┘
            ↕ REST API
┌─────────────────────────────────────┐
│     Spotify Web API                 │
│  - Authentication (OAuth 2.0)       │
│  - Search API (random tracks)       │
│  - Web Playback API (streaming)     │
└─────────────────────────────────────┘
```

### Request Flow

1. **User visits homepage** → Hono renders HTML with JSX
2. **User clicks "Login"** → OAuth flow to Spotify
3. **Spotify redirects back** → Exchange code for tokens, store in cookies
4. **Page loads with token** → Load Spotify SDK script
5. **SDK initializes** → Create Web Playback device
6. **User starts round** → Fetch random track, play via SDK
7. **Timer counts down** → JavaScript updates UI every second
8. **Round ends** → Show song info, update score

---

## 📁 File Structure

```
/home/user/webapp/
├── src/
│   ├── index.tsx              # Main Hono app - Routes & Server-side logic
│   └── renderer.tsx           # JSX renderer - HTML template wrapper
├── public/
│   └── static/
│       ├── app.js             # Frontend game logic (Vanilla JS)
│       └── style.css          # Custom CSS (minimal, mostly Tailwind)
├── dist/                      # Build output (generated by Vite)
│   ├── _worker.js             # Compiled Cloudflare Worker
│   ├── _routes.json           # Routing configuration
│   └── static/
│       ├── app.js             # Copied from public/static/
│       └── style.css          # Copied from public/static/
├── node_modules/              # Dependencies
├── .git/                      # Git repository
├── .dev.vars                  # Local environment variables (not in Git)
├── .gitignore                 # Git ignore rules
├── package.json               # Project dependencies & scripts
├── package-lock.json          # Locked dependency versions
├── tsconfig.json              # TypeScript configuration
├── vite.config.ts             # Vite build configuration
├── wrangler.jsonc             # Cloudflare Pages configuration
├── ecosystem.config.cjs       # PM2 configuration (for sandbox dev)
├── README.md                  # User-facing documentation
├── PROJECT_DOCUMENTATION.md   # This file - comprehensive technical docs
└── DEVELOPMENT_HISTORY.md     # Session-by-session change log
```

---

## 🔑 Key Components

### 1. Backend: `src/index.tsx`

**Purpose**: Main Hono application handling all routes and server logic

**Key Routes**:
- `GET /` - Home page with game interface
- `GET /login` - Initiates Spotify OAuth flow
- `GET /callback` - OAuth callback handler
- `GET /logout` - Clears authentication cookies
- `GET /api/token` - Returns access token for frontend
- `GET /api/random-track` - Fetches random track from Spotify
- `POST /api/auth/token` - Mobile app token exchange (legacy)
- `GET /api/mobile/random-track` - Mobile app track fetch (legacy)

**Important Functions**:
```typescript
// OAuth flow
app.get('/login') - Redirects to Spotify authorization
app.get('/callback') - Exchanges code for tokens, stores in cookies

// API endpoints
app.get('/api/token') - Returns cookie-stored access token
app.get('/api/random-track') - Uses Spotify Search API with random query
```

**HTML Structure** (JSX-rendered):
```jsx
<div id="game-area">
  {/* Duration Selector */}
  <div class="mb-6">
    <button class="duration-btn" data-duration="30">30 sec</button>
    <button class="duration-btn" data-duration="60">60 sec</button>
    <button class="duration-btn" data-duration="0">Full Song</button>
  </div>
  
  {/* Timer Display */}
  <div id="timer-display">30</div>
  <div id="timer-bar"></div>
  
  {/* Song Info */}
  <div id="song-info">Click "Start Round" to begin!</div>
  
  {/* Game Controls */}
  <button id="start-btn">Start Round</button>
  <button id="skip-btn" class="hidden">Skip (No Points)</button>
  <button id="logout-btn">Logout</button>
</div>

{/* Scripts loaded at bottom */}
<script src="https://sdk.scdn.co/spotify-player.js"></script>
<script src="/static/app.js"></script>
```

### 2. Renderer: `src/renderer.tsx`

**Purpose**: Wraps all pages with common HTML structure

**Key Elements**:
```jsx
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>🎵 Spotify Music Quiz</title>
  <script src="https://cdn.tailwindcss.com"></script>  {/* Critical! */}
  <link href="/static/style.css" rel="stylesheet" />
</head>
```

**IMPORTANT**: The Tailwind CDN script MUST be in renderer.tsx, not index.tsx!

### 3. Frontend: `public/static/app.js`

**Purpose**: Client-side game logic and Spotify SDK integration

**Game State Object**:
```javascript
let gameState = {
  round: 1,              // Current round number
  score: 0,              // Total points earned
  isPlaying: false,      // Is a round currently active?
  currentTrack: null,    // Current track object {id, name, artists, uri}
  timer: null,           // setInterval reference for countdown
  timeLeft: 30,          // Seconds remaining in current round
  duration: 30,          // Selected duration (30, 60, or 0 for full)
  durationLocked: false, // Has first round started? (locks duration)
  player: null,          // Spotify Player instance
  deviceId: null,        // Spotify device ID (assigned when ready)
  isMobile: false        // Is mobile device? (shows warning if true)
};
```

**Critical Functions**:

```javascript
// 1. EARLY SDK CALLBACK (TOP OF FILE - LINE 17-23)
window.onSpotifyWebPlaybackSDKReady = () => {
  // This callback is fired when SDK loads
  // Must be defined BEFORE SDK script loads
  if (window.spotifyPlayerInitializer) {
    window.spotifyPlayerInitializer();
  }
};

// 2. Initialize Spotify Player
async function initializeSpotifyPlayer() {
  // Fetches access token from server
  // Defines spotifyPlayerInitializer function
  // Creates Spotify.Player instance
  // Sets up event listeners (ready, not_ready, errors)
}

// 3. Duration Button Handlers (LINE 60-91)
document.querySelectorAll('.duration-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    if (gameState.durationLocked) return; // Can't change after game starts
    
    // Update button styling (highlight selected)
    // Update gameState.duration
    // Update timer display
  });
});

// 4. Lock Duration Buttons (LINE 103-110)
function lockDurationButtons() {
  // Called when first round starts
  // Disables all duration buttons
  // Adds opacity-50 and cursor-not-allowed classes
}

// 5. Start Round (LINE 195-237)
async function startRound() {
  // Lock duration if first round
  // Fetch random track from /api/random-track
  // Call playTrack(uri)
  // Start timer countdown
  // Update UI (hide Start, show Skip)
}

// 6. Play Track (LINE 239-267)
async function playTrack(uri) {
  // Uses Spotify Web Playback API
  // Plays track on gameState.deviceId
  // Handles Premium required errors
}

// 7. Start Timer (LINE 275-296)
function startTimer() {
  if (gameState.duration === 0) {
    // Full song mode - show ∞, no countdown
    return;
  }
  
  // Normal mode - countdown every second
  setInterval(() => {
    gameState.timeLeft--;
    // Update timer display and progress bar
    if (gameState.timeLeft <= 0) {
      endRound(true); // Timer ended, give point
    }
  }, 1000);
}

// 8. End Round (LINE 305-350)
async function endRound(earnedPoint) {
  // Stop playback
  // Update score if earnedPoint === true
  // Show song name and artist
  // Increment round number
  // Reset UI for next round
}
```

**Event Flow**:
```
Page Load
  → DOMContentLoaded fires
    → Attach button click handlers
    → Call initializeSpotifyPlayer()
      → Fetch access token
      → Define spotifyPlayerInitializer function
  → Spotify SDK script loads (async)
    → window.onSpotifyWebPlaybackSDKReady fires
      → Call spotifyPlayerInitializer()
        → Create Spotify.Player
        → Player connects
        → 'ready' event fires
          → Store device_id in gameState
          → Player ready! 🎉

User clicks duration button
  → Update gameState.duration
  → Highlight selected button
  → Update timer display

User clicks "Start Round"
  → Lock duration buttons (if first round)
  → Fetch random track
  → Play track on Spotify device
  → Start countdown timer
  → Hide Start button, show Skip button

Timer reaches 0
  → Stop playback
  → Update score (+1)
  → Show song name/artist
  → Show "Next Round" button

User clicks "Next Round"
  → Same as "Start Round" but duration already locked
```

---

## 🌐 API Endpoints

### Backend Endpoints (Hono)

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| GET | `/` | Home page | No |
| GET | `/login` | Start OAuth flow | No |
| GET | `/callback` | OAuth callback | No |
| GET | `/logout` | Clear session | No |
| GET | `/api/token` | Get access token | Yes (cookie) |
| GET | `/api/random-track` | Get random track | Yes (cookie) |
| POST | `/api/auth/token` | Mobile token exchange | No |
| GET | `/api/mobile/random-track` | Mobile track fetch | Yes (header) |

### Spotify API Endpoints Used

| Endpoint | Purpose | Used By |
|----------|---------|---------|
| `https://accounts.spotify.com/authorize` | OAuth authorization | `/login` route |
| `https://accounts.spotify.com/api/token` | Exchange code for token | `/callback` route |
| `https://api.spotify.com/v1/search` | Search for random tracks | `/api/random-track` |
| `https://api.spotify.com/v1/me/player/play` | Play track on device | `playTrack()` in app.js |

---

## 📊 Data Flow

### 1. Authentication Flow

```
User                Browser              Hono Server         Spotify API
  |                    |                      |                   |
  |-- Click Login ---->|                      |                   |
  |                    |--- GET /login ------>|                   |
  |                    |                      |-- OAuth Request ->|
  |                    |<-- Redirect to Spotify Auth -------------|
  |<-- Spotify Login Page --------------------------------|
  |-- Enter Credentials --------------------------------->|
  |                    |<-- Redirect /callback?code=xxx --|
  |                    |--- GET /callback?code=xxx ------>|
  |                    |                      |-- Exchange Code ->|
  |                    |                      |<-- Access Token --|
  |                    |<-- Set Cookie -------|
  |                    |<-- Redirect to / ----|
  |<-- Home Page ------|
```

### 2. Game Flow

```
Browser             app.js           Hono Server       Spotify API
  |                   |                   |                |
  |-- Load Page ----->|                   |                |
  |                   |-- GET /api/token ->|               |
  |                   |<-- Access Token ---|               |
  |                   |                   |                |
  |<-- Load SDK ------|                   |                |
  |                   |<-- SDK Ready -----|                |
  |                   |-- Init Player ----|--------------->|
  |                   |<-- Device Ready --|<---------------|
  |                   |                   |                |
  |-- Select 60s ---->|                   |                |
  |                   |-- Update State ---|                |
  |                   |                   |                |
  |-- Start Round --->|                   |                |
  |                   |-- Lock Duration --|                |
  |                   |-- GET /api/random-track ---------->|
  |                   |<-- Track Info -----|<--------------|
  |                   |-- Play Track ------|--------------->|
  |<-- Music Plays ---|<------------------|<---------------|
  |                   |-- Start Timer ----|                |
  |<-- Update UI -----|                   |                |
  |                   |... 60 seconds ...  |                |
  |                   |-- Timer End ------|                |
  |                   |-- Stop Playback --|--------------->|
  |<-- Show Answer ---|                   |                |
```

---

## 🚀 Deployment

### Prerequisites

1. **Cloudflare Account** - Free tier is sufficient
2. **Spotify Developer Account** - Create app at https://developer.spotify.com/dashboard
3. **Node.js 18+** - For local development
4. **Git** - For version control

### Environment Variables

**Development (.dev.vars)**:
```
SPOTIFY_CLIENT_ID=your_dev_client_id
SPOTIFY_CLIENT_SECRET=your_dev_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/callback
```

**Production (Cloudflare Secrets)**:
```bash
npx wrangler pages secret put SPOTIFY_CLIENT_ID --project-name spotify-music-quiz
npx wrangler pages secret put SPOTIFY_CLIENT_SECRET --project-name spotify-music-quiz
npx wrangler pages secret put SPOTIFY_REDIRECT_URI --project-name spotify-music-quiz
# Use: https://spotify-music-quiz.pages.dev/callback
```

### Deployment Commands

**Build**:
```bash
npm run build
# Output: dist/ folder with _worker.js and static files
```

**Deploy to Production**:
```bash
npx wrangler pages deploy dist --project-name spotify-music-quiz --branch main --commit-dirty=true
```

**Expected Output**:
```
✨ Success! Uploaded 3 files (0.5 sec)
✨ Deployment complete! Take a peek over at https://[preview-hash].spotify-music-quiz.pages.dev
🌎 https://spotify-music-quiz.pages.dev (Production)
```

### Spotify App Configuration

**Redirect URIs to Add**:
- Development: `http://localhost:3000/callback`
- Production: `https://spotify-music-quiz.pages.dev/callback`

**Required Scopes**:
- `streaming` - Play music in Web Playback SDK
- `user-read-email` - User identification
- `user-read-private` - User identification
- `user-modify-playback-state` - Control playback
- `user-read-playback-state` - Check playback status

---

## 🐛 Common Issues & Solutions

### Issue 1: "Waiting for Spotify player to connect"

**Symptoms**:
- Click "Start Round" → Error message
- Console: "Spotify SDK not loaded" or no device ID

**Causes**:
- `window.onSpotifyWebPlaybackSDKReady` not defined early enough
- Script loading order incorrect
- Access token invalid

**Solutions**:
1. **Check script order in index.tsx**:
   ```jsx
   {/* Spotify SDK MUST load before app.js */}
   <script src="https://sdk.scdn.co/spotify-player.js"></script>
   <script src="/static/app.js"></script>
   ```

2. **Verify early callback in app.js** (lines 17-23):
   ```javascript
   // MUST be at TOP of file, not inside a function
   window.onSpotifyWebPlaybackSDKReady = () => {
     if (window.spotifyPlayerInitializer) {
       window.spotifyPlayerInitializer();
     }
   };
   ```

3. **Check console for device ID**:
   ```
   ✅ Correct: "Ready with Device ID [hash]"
   ❌ Wrong: No device ID message
   ```

### Issue 2: Duration Buttons Not Working

**Symptoms**:
- Click duration button → Nothing happens
- No highlighting, no console logs

**Causes**:
- Missing Tailwind CSS (most common!)
- JavaScript not attaching event listeners
- Button elements not found in DOM

**Solutions**:
1. **Check renderer.tsx has Tailwind CDN**:
   ```jsx
   <script src="https://cdn.tailwindcss.com"></script>
   ```

2. **Check console for errors**:
   ```
   ✅ Should see: "Duration changed to: 60 seconds"
   ❌ Errors: "Cannot read property of null"
   ```

3. **Verify buttons exist in HTML**:
   - Open DevTools → Elements tab
   - Search for `class="duration-btn"`
   - Should find 3 buttons

### Issue 3: Two Duration Selectors Appear

**Cause**: Old cached version of site

**Solution**:
1. Hard refresh: `Ctrl + Shift + R` (Windows) or `Cmd + Shift + R` (Mac)
2. Clear site data:
   - DevTools → Application tab
   - Click "Clear site data"
   - Refresh page

### Issue 4: OAuth Redirect Error

**Symptoms**:
- After Spotify login → "Error: No authorization code"
- URL shows `?error=...`

**Causes**:
- Redirect URI mismatch
- Client ID/Secret incorrect

**Solutions**:
1. **Check Spotify app settings**:
   - Go to https://developer.spotify.com/dashboard
   - Open your app
   - Redirect URIs MUST match exactly (including http/https, port, path)

2. **Check environment variables**:
   ```bash
   # Local
   cat .dev.vars
   
   # Production
   npx wrangler pages secret list --project-name spotify-music-quiz
   ```

### Issue 5: "Premium Required" Error

**Symptoms**:
- Music doesn't play
- Console: "PREMIUM_REQUIRED"

**Cause**: Spotify Free account (Web Playback SDK requires Premium)

**Solution**: Upgrade to Spotify Premium

---

## 🔮 Future Development

### Planned Features

1. **High Score Leaderboard**
   - Add Cloudflare D1 database
   - Store top scores with usernames
   - Display leaderboard on homepage

2. **Difficulty Levels**
   - Easy: Show album art
   - Medium: Current behavior
   - Hard: Only instrumental parts

3. **Playlist Selection**
   - Let users choose genres (Pop, Rock, Hip-Hop, etc.)
   - Fetch tracks from specific playlists
   - User's own playlist support

4. **Multiplayer Mode**
   - WebSocket support via Cloudflare Durable Objects
   - Real-time competition
   - Shared game rooms

5. **Hints System**
   - "Show first letter"
   - "Show release year"
   - "Show genre"
   - Costs points to use

### Architecture Improvements

1. **Add D1 Database**:
   ```bash
   npx wrangler d1 create spotify-music-quiz-db
   ```
   - Store high scores
   - User profiles
   - Game statistics

2. **Add KV Storage**:
   ```bash
   npx wrangler kv:namespace create spotify-quiz-cache
   ```
   - Cache random tracks
   - Store session data

3. **Optimize Track Selection**:
   - Current: Random search (sometimes poor results)
   - Improved: Curated track database
   - Better randomization algorithm

4. **Add Service Worker**:
   - Offline support
   - Faster loading
   - PWA capabilities

### Code Quality Improvements

1. **TypeScript for Frontend**:
   - Convert app.js to TypeScript
   - Add type safety
   - Better IDE support

2. **Testing**:
   - Unit tests for game logic
   - E2E tests with Playwright
   - API endpoint tests

3. **Monitoring**:
   - Add Cloudflare Analytics
   - Error tracking
   - Performance monitoring

---

## 📞 Support & Contact

- **GitHub Issues**: https://github.com/nirtituani/spotify-music-quiz/issues
- **Production URL**: https://spotify-music-quiz.pages.dev/
- **Spotify Developer**: https://developer.spotify.com/support

---

## 📄 License

MIT License - Feel free to use and modify!

---

**Last Updated**: 2025-11-05  
**Document Version**: 1.0  
**Project Version**: 1.1.0
