# Deploy Mobile Backend Update

## What Was Changed

✅ **Added `/api/auth/token` endpoint** to `src/index.tsx`

This new endpoint handles mobile OAuth token exchange:
- Accepts `POST` requests with `code` and `redirect_uri`
- Exchanges authorization code for Spotify access token
- Returns tokens to mobile app (stored in AsyncStorage)
- Supports both web and mobile redirect URIs

## Deploy to Production

### Option 1: Automatic Deployment (if you have Cloudflare API key set up)

```bash
cd /home/user/webapp
npx wrangler pages deploy dist --project-name spotify-music-quiz
```

### Option 2: Manual Deployment via Cloudflare Dashboard

1. **Build is already complete** (see `dist/` folder)
2. **Go to**: https://dash.cloudflare.com
3. **Navigate to**: Pages → spotify-music-quiz
4. **Upload the new build**: Drag and drop the `dist/` folder

### Option 3: Via GitHub (if connected)

```bash
cd /home/user/webapp

# Commit the changes
git add src/index.tsx
git commit -m "Add mobile OAuth token exchange endpoint"
git push origin main

# Cloudflare will auto-deploy from GitHub
```

## Verify Deployment

After deployment, test the endpoint:

```bash
curl -X POST https://spotify-music-quiz.pages.dev/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"code":"test","redirect_uri":"spotifymusicquiz://callback"}'
```

You should get an error about invalid code (that's expected), but NOT a 404 error.

## What This Fixes

Before:
- ❌ Mobile app redirected back from Spotify
- ❌ Tried to call `/api/auth/token` → 404 error
- ❌ "invalid client" error shown to user

After:
- ✅ Mobile app redirected back from Spotify
- ✅ Calls `/api/auth/token` → endpoint exists
- ✅ Backend exchanges code for token
- ✅ Mobile app receives token and logs in successfully

## Testing on Mobile After Deployment

1. **Wait 1-2 minutes** for deployment to complete
2. **Open your React Native app**
3. **Tap "Login with Spotify"**
4. **Log in** with Spotify
5. **Should redirect back** and log in successfully!

## The New Endpoint

```typescript
POST /api/auth/token
Content-Type: application/json

{
  "code": "AQD...",
  "redirect_uri": "spotifymusicquiz://callback"
}

Response:
{
  "access_token": "BQC...",
  "refresh_token": "AQA...",
  "expires_in": 3600
}
```

This endpoint:
- Accepts the authorization code from Spotify
- Exchanges it for an access token using your Client ID/Secret (secure on server)
- Returns the token to the mobile app
- Works with both web and mobile redirect URIs

---

## Summary

✅ Backend code updated
✅ Build complete
⏳ Need to deploy to Cloudflare Pages
✅ Mobile app already has the code to call this endpoint

**Deploy now and test the mobile login!** 🚀
