# 🤖 Quick Start Guide for AI Assistants

This file helps AI assistants quickly understand the project when starting a new conversation.

---

## 📖 Required Reading (In Order)

1. **[PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)** ⭐ MOST IMPORTANT
   - Complete architecture overview
   - File structure and key components
   - API endpoints and data flow
   - Common issues and solutions

2. **[DEVELOPMENT_HISTORY.md](DEVELOPMENT_HISTORY.md)**
   - What changed in each session
   - Why decisions were made
   - Bugs fixed and lessons learned

3. **[README.md](README.md)**
   - User-facing documentation
   - Current features and status
   - Deployment instructions

---

## 🎯 Project At A Glance

**Type**: Web-based music quiz game  
**Platform**: Cloudflare Pages (Edge)  
**Backend**: Hono (TypeScript)  
**Frontend**: Vanilla JavaScript + Tailwind CSS  
**Version**: 1.1.0  
**Status**: ✅ Fully Functional  

**Production URL**: https://spotify-music-quiz.pages.dev/  
**GitHub**: https://github.com/nirtituani/spotify-music-quiz

---

## 🗂️ Key Files to Know

| File | Purpose | Critical? |
|------|---------|-----------|
| `src/index.tsx` | Main Hono app - all routes | ⭐⭐⭐ |
| `public/static/app.js` | Frontend game logic | ⭐⭐⭐ |
| `src/renderer.tsx` | HTML wrapper (has Tailwind CDN!) | ⭐⭐ |
| `wrangler.jsonc` | Cloudflare configuration | ⭐⭐ |
| `package.json` | Dependencies & scripts | ⭐ |

---

## ⚠️ Critical Things to Remember

### 1. Script Loading Order MATTERS

```jsx
{/* In src/index.tsx - MUST be this order! */}
<script src="https://sdk.scdn.co/spotify-player.js"></script>
<script src="/static/app.js"></script>
```

### 2. Spotify SDK Callback MUST Be at Top of app.js

```javascript
// public/static/app.js - LINE 17-23
// This MUST be defined BEFORE any functions!
window.onSpotifyWebPlaybackSDKReady = () => {
  if (window.spotifyPlayerInitializer) {
    window.spotifyPlayerInitializer();
  }
};
```

### 3. Tailwind CSS MUST Be in renderer.tsx

```jsx
// src/renderer.tsx - REQUIRED!
<script src="https://cdn.tailwindcss.com"></script>
```

### 4. Duration Locking Mechanism

Duration selector can ONLY be changed BEFORE first round starts. After clicking "Start Round", it's locked for the entire game session.

```javascript
// In startRound() function
if (!gameState.durationLocked) {
  gameState.durationLocked = true;
  lockDurationButtons(); // Disables and grays out buttons
}
```

---

## 🐛 Common Issues

### "Waiting for Spotify player to connect"
**Cause**: SDK callback not defined early enough  
**Solution**: Check app.js line 17-23 has the callback at TOP level

### Duration buttons not working
**Cause**: Missing Tailwind CSS  
**Solution**: Check renderer.tsx has Tailwind CDN script

### Two duration selectors appear
**Cause**: Browser cache  
**Solution**: Hard refresh (Ctrl+Shift+R)

---

## 🚀 Deployment Process

```bash
# On user's Windows machine
cd C:\Users\nir.tituani\spotify-music-quiz
git pull origin main
npm run build
npx wrangler pages deploy dist --project-name spotify-music-quiz --branch main --commit-dirty=true
```

---

## 📂 Project Structure

```
/home/user/webapp/
├── src/
│   ├── index.tsx         # ⭐ Main Hono app (all routes)
│   └── renderer.tsx      # ⭐ HTML wrapper (Tailwind CDN here!)
├── public/static/
│   ├── app.js           # ⭐ Frontend game logic (SDK callback here!)
│   └── style.css        # Custom CSS (minimal)
├── dist/                # Build output (don't edit directly)
├── wrangler.jsonc       # Cloudflare config
├── package.json         # Dependencies & scripts
└── README.md            # User docs
```

---

## 💾 Backup Location

**Latest Working Version**: https://page.gensparksite.com/project_backups/spotify-music-quiz-working-v1.1.0.tar.gz

Use this to restore if something breaks!

---

## 🎮 How the Game Works (Tech View)

1. User logs in → OAuth flow → Store tokens in cookies
2. Page loads → Load Spotify SDK script → SDK fires callback
3. Callback creates Web Playback device → Get device_id
4. User selects duration (30s, 60s, or Full) → Update gameState
5. User clicks "Start Round" → Lock duration → Fetch random track
6. Play track on device_id → Start countdown timer
7. Timer ends → Show song name → Update score
8. User clicks "Next Round" → Repeat from step 5 (same duration)

---

## 🔮 Future Features (Potential)

- High score leaderboard (needs Cloudflare D1)
- Difficulty levels (show/hide hints)
- Playlist selection (genres, user playlists)
- Multiplayer mode (needs WebSockets/Durable Objects)

---

## 📞 When User Starts New Conversation

**Copy-paste this prompt template**:

```
I'm working on the Spotify Music Quiz project. Here's the context:

**Project**: https://spotify-music-quiz.pages.dev/
**GitHub**: https://github.com/nirtituani/spotify-music-quiz

Please read these files for full context:
1. PROJECT_DOCUMENTATION.md (architecture & structure)
2. DEVELOPMENT_HISTORY.md (what changed and why)

**Current Issue**: [User describes what they want to work on]

Can you help me implement this?
```

---

**Last Updated**: 2025-11-05  
**For**: AI Assistants starting new conversations  
**Version**: 1.0
