#!/bin/bash
# Deploy ryspai.com: sync content from OBS, build, commit, push.
# Called by the Obsidian "ryspai.com Assets Sync" plugin.

set -euo pipefail

OBS_CONTENT="/Users/ryspaisensei/Мой диск/OBS/ryspai.com"
SITE_DIR="/Users/ryspaisensei/code/ryspai-site"

cd "$SITE_DIR"

echo "→ Syncing content from OBS..."
rm -rf content
mkdir -p content
cp -R "$OBS_CONTENT/"* content/

echo "→ Staging changes..."
git add -A

if git diff --cached --quiet; then
  echo "✓ No changes to push."
  exit 0
fi

# Auto commit message: count of changed files + timestamp
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
MSG="Sync from Obsidian: $STAGED file(s) changed [$(date '+%Y-%m-%d %H:%M')]"

echo "→ Committing: $MSG"
git commit -m "$MSG"

echo "→ Pushing to GitHub..."
git push

echo "✓ Done. Deploy will run on GitHub Actions in ~1 min."
