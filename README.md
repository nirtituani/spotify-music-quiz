# 🎵 Spotify Music Quiz

A fun interactive music quiz game that tests your music knowledge using Spotify's library. Listen to 30-second clips and see how many songs you can recognize!

## 🌐 Live Demo

- **Production**: https://spotify-music-quiz.pages.dev/
- **GitHub**: https://github.com/nirtituani/spotify-music-quiz

## ✨ Features

### Currently Completed
- ✅ Spotify OAuth authentication
- ✅ Full song playback using Web Playback SDK
- ✅ **Song duration selector** (30 sec, 60 sec, or Full Song)
- ✅ Duration locked after first round starts (same for all songs)
- ✅ Round-based scoring system
- ✅ Timer countdown with visual progress bar
- ✅ Skip functionality (no points awarded)
- ✅ Responsive design with Tailwind CSS
- ✅ **Desktop-only mode** 🖥️ (mobile shows informative warning)
- ✅ Automatic device detection
- ✅ Session management with secure cookies
- ✅ Random song selection from Spotify's library

### Functional Entry Points
- `GET /` - Home page with game interface
- `GET /login` - Initiates Spotify OAuth flow
- `GET /callback` - OAuth callback handler
- `GET /logout` - Clears authentication and logs out
- `GET /api/token` - Returns current user's Spotify access token
- `GET /api/random-track` - Fetches a random track from Spotify

### Not Yet Implemented
- ⏳ High score leaderboard
- ⏳ Multiple difficulty levels
- ⏳ Custom playlist selection
- ⏳ Multiplayer mode
- ⏳ Song hints or multiple choice options
- ⏳ Share score on social media

### Recommended Next Steps
1. Add D1 database to store high scores
2. Implement difficulty levels (easy: show album art, hard: instrumental only)
3. Add playlist selection (e.g., "90s hits", "Rock", "Pop")
4. Create a leaderboard system
5. Add sound effects and animations
6. Implement user profiles and statistics

## 🎮 How to Play

⚠️ **Desktop/Laptop Only** - This quiz requires a computer (not mobile phone/tablet)

1. **Login** with your Spotify Premium account
2. **Choose song duration** (30 sec, 60 sec, or Full Song) - you can only choose before the first round!
3. **Click "Start Round"** to begin a round
4. **Listen** to the song clip (duration you selected will be used for all rounds)
5. **Wait** for the timer to end to earn 1 point and see the answer
6. **Or Skip** anytime to see the answer immediately (no points)
7. **Keep playing** to increase your score!

### Why Desktop Only?

Mobile browsers are not supported because:
- The quiz needs to **hide the song name** from you (that's the whole point!)
- Spotify Web Playback SDK (the only way to hide song names) doesn't work on mobile browsers
- Preview URLs don't work for all songs
- Playing through the Spotify app would show the song name and ruin the quiz
3. **Click "Start Round"** - music will play through your Spotify app
4. **Listen** for 30 seconds
5. **Wait** for timer to end to earn 1 point, or **Skip** for no points
6. **Keep playing** to increase your score!

**Important**: On mobile, you MUST have the Spotify app open and playing first, then the quiz will control playback.

## 🛠️ Tech Stack

- **Backend**: Hono (lightweight web framework for Cloudflare Workers)
- **Frontend**: HTML, Vanilla JavaScript, Tailwind CSS
- **Platform**: Cloudflare Pages
- **APIs**: Spotify Web API & Web Playback SDK
- **Authentication**: OAuth 2.0 with secure HTTP-only cookies

## 📦 Data Architecture

### Data Models
- **Game State** (client-side):
  - `round`: Current round number
  - `score`: Player's total score
  - `currentTrack`: Active song details
  - `timeLeft`: Remaining seconds in round
  - `duration`: Selected song duration (30, 60, or 0 for full song)
  - `durationLocked`: Whether duration can still be changed
  - `isPlaying`: Game status flag

- **Session Data** (server-side cookies):
  - `spotify_access_token`: OAuth access token (expires in 1 hour)
  - `spotify_refresh_token`: Refresh token for long-term access

### Storage Services
- **Cookies**: Session management and token storage
- **Future**: Cloudflare D1 for high scores and user profiles

### Data Flow
1. User authenticates via Spotify OAuth
2. Tokens stored in secure HTTP-only cookies
3. Client requests access token from `/api/token`
4. Client fetches random track from `/api/random-track`
5. Spotify Web Playback SDK plays the track
6. Game state managed client-side
7. Scores updated in real-time (future: synced to D1)

## 🚀 Local Development

### Prerequisites
- Node.js 18+ 
- Spotify Premium account
- Spotify Developer App credentials

### Setup Spotify App

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Add redirect URI: `http://localhost:3000/callback`
4. Copy Client ID and Client Secret

### Installation

```bash
# Install dependencies
npm install

# Configure environment variables
# Edit .dev.vars with your Spotify credentials:
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
SPOTIFY_REDIRECT_URI=http://localhost:3000/callback

# Build the project
npm run build

# Start development server with PM2
pm2 start ecosystem.config.cjs

# Or use npm script
npm run dev:sandbox

# Test the application
curl http://localhost:3000
```

### Available Scripts

- `npm run dev` - Start Vite dev server
- `npm run dev:sandbox` - Start with Wrangler Pages (for sandbox)
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run deploy` - Deploy to Cloudflare Pages
- `npm run deploy:prod` - Deploy with project name
- `npm run clean-port` - Kill process on port 3000
- `npm run test` - Test local server with curl

## 🌍 Production Deployment

### Setup Cloudflare

```bash
# Login to Cloudflare (one-time setup)
# Use setup_cloudflare_api_key tool in sandbox

# Build the project
npm run build

# Create Cloudflare Pages project
npx wrangler pages project create spotify-music-quiz \
  --production-branch main

# Deploy to production
npm run deploy:prod

# Set environment variables (secrets)
npx wrangler pages secret put SPOTIFY_CLIENT_ID --project-name spotify-music-quiz
npx wrangler pages secret put SPOTIFY_CLIENT_SECRET --project-name spotify-music-quiz
npx wrangler pages secret put SPOTIFY_REDIRECT_URI --project-name spotify-music-quiz
# For production, use: https://spotify-music-quiz.pages.dev/callback
```

### Update Spotify App Settings

After deployment, add production redirect URI to your Spotify app:
- `https://spotify-music-quiz.pages.dev/callback`

## 🔒 Security Notes

- Access tokens stored in HTTP-only cookies (not accessible via JavaScript)
- Tokens expire after 1 hour for security
- Client ID/Secret stored as Cloudflare secrets (not in code)
- OAuth 2.0 authorization code flow implemented
- Secure cookie flags: `httpOnly`, `secure`, `sameSite`

## 📄 Requirements

- **Desktop or Laptop Computer**: Windows, Mac, or Linux (**mobile not supported**)
- **Spotify Premium Account**: Required for Web Playback SDK
- **Modern Browser**: Chrome, Firefox, Safari, or Edge (desktop versions only)
- **Active Internet Connection**: For streaming music from Spotify

## 🐛 Troubleshooting

**"Authentication failed" error**
- Re-login with Spotify
- Check if Spotify credentials are correctly set
- Verify redirect URI matches in Spotify app settings

**"Spotify Premium required" error**
- Web Playback SDK requires Premium account
- Free accounts cannot stream full tracks

**No sound playing**
- Check browser permissions for audio
- Ensure Spotify Premium account is active
- Try refreshing the page

**"Failed to load track" error**
- Check internet connection
- Token may have expired - try re-logging in
- Spotify API may be temporarily unavailable

## 📝 License

MIT License - Feel free to use and modify!

## 🙏 Credits

- Spotify Web API & Web Playback SDK
- Hono Framework
- Cloudflare Pages
- Tailwind CSS

---

**Last Updated**: 2025-11-05  
**Status**: ✅ Active  
**Version**: 1.1.0
