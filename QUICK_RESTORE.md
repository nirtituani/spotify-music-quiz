# 🚨 Quick Restore Reference

## To Restore to Last Working Version:

```bash
cd ~/spotify-music-quiz
git fetch --tags
git checkout v1.0-ios-working
```

## To View All Backups:

```bash
cd ~/spotify-music-quiz
git tag -l
```

## To Compare Current vs Backup:

```bash
cd ~/spotify-music-quiz
git diff v1.0-ios-working
```

## Emergency Reset (⚠️ Loses all changes):

```bash
cd ~/spotify-music-quiz
git reset --hard v1.0-ios-working
```

---

📖 **Full Instructions:** See `BACKUP_RESTORE.md`
