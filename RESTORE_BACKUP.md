# 🔄 How to Restore Backups - Spotify Music Quiz

This guide explains how to restore the project to the v1.1.0 working state if something goes wrong.

---

## 📍 Backup Points Created

**Version**: 1.1.0  
**Date**: 2025-11-05  
**Status**: ✅ Fully functional (duration selector working, Spotify connected)  
**Commit Hash**: `695474e`

### Backup Locations

1. **Git Tag**: `v1.1.0`
2. **Backup Branch**: `backup/v1.1.0-working`
3. **Tar.gz Archive**: https://page.gensparksite.com/project_backups/spotify-music-quiz-working-v1.1.0.tar.gz
4. **GitHub Release**: https://github.com/nirtituani/spotify-music-quiz/releases/tag/v1.1.0

---

## 🚀 Restoration Methods

### Method 1: Restore from Git Tag (RECOMMENDED)

**When to use**: When you want to quickly revert to v1.1.0

**Steps**:
```bash
cd C:\Users\nir.tituani\spotify-music-quiz

# See all available tags
git tag -l

# Restore to v1.1.0 tag
git checkout v1.1.0

# If you want to continue development from this point, create a new branch
git checkout -b fix-from-v1.1.0

# Or if you want to reset main branch to this point (DESTRUCTIVE!)
git checkout main
git reset --hard v1.1.0
git push -f origin main  # ⚠️ Force push - be careful!
```

**Result**: Your code will be exactly as it was at v1.1.0

---

### Method 2: Restore from Backup Branch

**When to use**: When you want a full branch to work from

**Steps**:
```bash
cd C:\Users\nir.tituani\spotify-music-quiz

# Fetch all branches
git fetch --all

# Switch to backup branch
git checkout backup/v1.1.0-working

# Or merge backup into main
git checkout main
git merge backup/v1.1.0-working
```

**Result**: You have a full branch with the working code

---

### Method 3: Restore from Specific Commit

**When to use**: When you know the exact commit hash

**Steps**:
```bash
cd C:\Users\nir.tituani\spotify-music-quiz

# View commit history
git log --oneline -20

# Reset to specific commit (v1.1.0 = 695474e)
git reset --hard 695474e

# Push to GitHub (if needed)
git push -f origin main  # ⚠️ Force push
```

**Result**: Code restored to exact commit

---

### Method 4: Restore from Tar.gz Archive

**When to use**: When Git is corrupted or you need a fresh copy

**Steps**:
```bash
# 1. Download the tar.gz file
# URL: https://page.gensparksite.com/project_backups/spotify-music-quiz-working-v1.1.0.tar.gz

# 2. Extract to a new location
cd C:\Users\nir.tituani\
tar -xzf spotify-music-quiz-working-v1.1.0.tar.gz
# This creates: C:\Users\nir.tituani\webapp\

# 3. If you want to replace existing project
cd C:\Users\nir.tituani\
rm -rf spotify-music-quiz  # Delete old folder
tar -xzf spotify-music-quiz-working-v1.1.0.tar.gz
mv webapp spotify-music-quiz  # Rename to original name

# 4. Reinstall dependencies and rebuild
cd spotify-music-quiz
npm install
npm run build
```

**Result**: Fresh copy of v1.1.0 with all files and Git history

---

### Method 5: Clone from GitHub

**When to use**: Starting fresh on a new machine

**Steps**:
```bash
# Clone the repository
git clone https://github.com/nirtituani/spotify-music-quiz.git
cd spotify-music-quiz

# Checkout v1.1.0 tag
git checkout v1.1.0

# Or checkout backup branch
git checkout backup/v1.1.0-working

# Install and build
npm install
npm run build
```

**Result**: Fresh clone from GitHub

---

## 🔍 Verify Restoration

After restoring, verify you have the correct version:

### Check Git Status
```bash
cd C:\Users\nir.tituani\spotify-music-quiz
git log --oneline -1
# Should show: 695474e Add QUICK_START_FOR_AI.md

git describe --tags
# Should show: v1.1.0 or v1.1.0-X-gXXXXXXX
```

### Check Key Files
```bash
# Check if duration selector exists in index.tsx
grep -n "duration-btn" src/index.tsx
# Should show 3 buttons (30 sec, 60 sec, Full Song)

# Check if SDK callback is at top of app.js
head -25 public/static/app.js | grep "onSpotifyWebPlaybackSDKReady"
# Should show the callback definition

# Check if Tailwind is in renderer.tsx
grep "tailwindcss" src/renderer.tsx
# Should show: <script src="https://cdn.tailwindcss.com"></script>
```

### Test Functionality
```bash
# Build and test locally
npm install
npm run build
npx wrangler pages dev dist --ip 0.0.0.0 --port 3000

# Open browser: http://localhost:3000
# Test:
# 1. Duration buttons clickable and highlight
# 2. Start Round connects to Spotify (check console for device ID)
# 3. Music plays
# 4. Duration buttons lock after first round
```

---

## 📋 Comparison: What's in v1.1.0?

### Features
- ✅ Spotify OAuth authentication
- ✅ Song duration selector (30s, 60s, Full Song)
- ✅ Duration locking after first round
- ✅ Spotify Web Playback SDK integration
- ✅ Round-based scoring
- ✅ Skip functionality
- ✅ Desktop-only mode with mobile warning

### Bug Fixes
- ✅ Tailwind CSS included in renderer.tsx
- ✅ Spotify SDK callback defined early (line 17 of app.js)
- ✅ Script loading order correct (SDK before app.js)
- ✅ Duration buttons work and lock properly

### Documentation
- ✅ PROJECT_DOCUMENTATION.md (comprehensive)
- ✅ DEVELOPMENT_HISTORY.md (session log)
- ✅ QUICK_START_FOR_AI.md (AI assistant guide)
- ✅ RESTORE_BACKUP.md (this file)
- ✅ Updated README.md

---

## 🆘 Emergency Recovery

If everything is broken and you can't access Git:

1. **Download tar.gz backup**: https://page.gensparksite.com/project_backups/spotify-music-quiz-working-v1.1.0.tar.gz
2. **Extract and replace** your project folder
3. **Reinstall dependencies**: `npm install`
4. **Rebuild**: `npm run build`
5. **Test locally**: `npx wrangler pages dev dist`

---

## 📊 Before/After Comparison

### Before v1.1.0
```
❌ No duration selector
❌ Spotify connection timing issues
❌ Missing Tailwind CSS
❌ Limited documentation
```

### After v1.1.0
```
✅ Duration selector (30s, 60s, Full Song)
✅ Duration locks after first round
✅ Spotify connects reliably
✅ All styling working (Tailwind included)
✅ Comprehensive documentation
✅ Multiple backup methods
```

---

## 🔐 GitHub Access

All backups are accessible on GitHub:

- **Main Repository**: https://github.com/nirtituani/spotify-music-quiz
- **Tag v1.1.0**: https://github.com/nirtituani/spotify-music-quiz/releases/tag/v1.1.0
- **Backup Branch**: https://github.com/nirtituani/spotify-music-quiz/tree/backup/v1.1.0-working
- **Commit 695474e**: https://github.com/nirtituani/spotify-music-quiz/commit/695474e

---

## 💡 Best Practices

### Before Making Changes
1. **Create a new branch**: `git checkout -b feature/new-feature`
2. **Tag current state**: `git tag -a v1.1.1-pre -m "Before adding new feature"`
3. **Commit frequently**: `git commit -m "Clear message"`

### After Testing Changes
1. **Merge to main**: `git checkout main && git merge feature/new-feature`
2. **Create new tag**: `git tag -a v1.2.0 -m "Added new feature"`
3. **Push everything**: `git push origin main --tags`

### If Something Breaks
1. **Don't panic** - You have 4 backup methods!
2. **Check Git log**: `git log --oneline -10`
3. **Restore to v1.1.0**: `git reset --hard v1.1.0`
4. **Try again** with smaller changes

---

## 📞 Need Help?

1. **Read PROJECT_DOCUMENTATION.md** for technical details
2. **Read DEVELOPMENT_HISTORY.md** for context on changes
3. **Start new AI conversation** with QUICK_START_FOR_AI.md
4. **Check GitHub Issues** for similar problems

---

**Created**: 2025-11-05  
**Version**: 1.0  
**For Project**: Spotify Music Quiz v1.1.0
