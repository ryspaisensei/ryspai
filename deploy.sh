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
  echo "✓ Нет новых изменений для коммита."
else
  STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
  MSG="Sync from Obsidian: $STAGED file(s) changed [$(date '+%Y-%m-%d %H:%M')]"
  echo "→ Committing: $MSG"
  git commit -m "$MSG"
fi

# Push only if there are unpushed local commits
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [ -z "$UPSTREAM" ]; then
  echo "→ Pushing (no upstream set yet)..."
  git push
elif [ "$(git rev-list --count "$UPSTREAM"..HEAD)" -gt 0 ]; then
  AHEAD=$(git rev-list --count "$UPSTREAM"..HEAD)
  echo "→ Pushing $AHEAD unpushed commit(s) to GitHub..."
  git push
  echo "✓ Done. Deploy will run on GitHub Actions in ~1 min."
else
  echo "✓ Локальная ветка совпадает с GitHub — пушить нечего."
fi
