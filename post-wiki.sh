#!/bin/bash
set -ex

# https://betterdev.blog/minimal-safe-bash-script-template/
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' SIGINT SIGTERM ERR EXIT

# https://weblog.west-wind.com/posts/2023/Jan/05/Fix-that-damn-Git-Unsafe-Repository
git config --global --add safe.directory "$tmp_dir"

PROTO="`echo $INPUT_GITEA_SERVER_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
URL=`echo $INPUT_GITEA_SERVER_URL | sed -e s,$proto,,g`

git clone "$PROTO$INPUT_TOKEN$URL/$INPUT_REPOSITORY.wiki.git" "$tmp_dir"

# Hidden files (like .myfile.txt, .git/, or .gitignore) are NOT copied.
rm -rf "${tmp_dir:?}"/*
cp -afv "$INPUT_PATH"/* "$tmp_dir/"

cd "$tmp_dir"

git config user.name "$INPUT_USERNAME"
git config user.email "$INPUT_USEREMAIL"

git add -Av
git commit --allow-empty -m 'Deploy wiki'

git push origin master

echo "wikiUrl=$INPUT_GITEA_SERVER_URL/$INPUT_REPOSITORY/wiki" >> "$GITHUB_OUTPUT"