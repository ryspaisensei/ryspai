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

python3 - "$OBS_CONTENT" "$SITE_DIR/content" <<'PYEOF'
import sys, os, shutil, re

SRC, DST = sys.argv[1], sys.argv[2]

TRANSLIT = {
    'а':'a','б':'b','в':'v','г':'g','д':'d','е':'e','ё':'yo','ж':'zh','з':'z',
    'и':'i','й':'j','к':'k','л':'l','м':'m','н':'n','о':'o','п':'p','р':'r',
    'с':'s','т':'t','у':'u','ф':'f','х':'kh','ц':'ts','ч':'ch','ш':'sh',
    'щ':'shch','ъ':'','ы':'y','ь':'','э':'e','ю':'yu','я':'ya',
}

def slugify(name):
    stem, ext = os.path.splitext(name)
    s = ''.join(TRANSLIT.get(c, TRANSLIT.get(c.lower(), c)) for c in stem)
    s = s.lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = s.strip('-')
    return s + ext

SKIP_DIRS = {'.claude', '.obsidian', '.git', 'node_modules'}

WIKI_LINK_RE = re.compile(r'\[\[([^\]|#]+?)(\|[^\]]+?)?\]\]')

def transliterate_wiki_links(content):
    def replace(m):
        target = m.group(1)
        alias = m.group(2) or ''
        # Если target содержит кириллицу — транслитерируем
        if re.search(r'[а-яёА-ЯЁ]', target):
            # Сохраняем путь (папки) отдельно от имени файла
            parts = target.rsplit('/', 1)
            if len(parts) == 2:
                new_target = parts[0] + '/' + slugify(parts[1])
            else:
                new_target = slugify(target)
            return f'[[{new_target}{alias}]]'
        return m.group(0)
    return WIKI_LINK_RE.sub(replace, content)

def copy_tree(src, dst):
    os.makedirs(dst, exist_ok=True)
    for entry in os.scandir(src):
        name = entry.name
        if name.startswith('.') or name in SKIP_DIRS:
            continue
        if entry.is_dir():
            # assets оставляем как есть (картинки, не нужен slug)
            new_name = name if name == 'assets' else slugify(name)
            copy_tree(entry.path, os.path.join(dst, new_name))
        else:
            if name.endswith('.md'):
                new_name = name if name == 'index.md' else slugify(name)
                with open(entry.path, 'r', encoding='utf-8') as f:
                    content = f.read()
                content = transliterate_wiki_links(content)
                with open(os.path.join(dst, new_name), 'w', encoding='utf-8') as f:
                    f.write(content)
            else:
                shutil.copy2(entry.path, os.path.join(dst, name))

copy_tree(SRC, DST)
print(f"  Copied {sum(len(f) for _,_,f in os.walk(DST))} files")
PYEOF

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
