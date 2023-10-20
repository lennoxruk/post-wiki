#!/bin/bash
set -ex

# https://betterdev.blog/minimal-safe-bash-script-template/
TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' SIGINT SIGTERM ERR EXIT

# https://weblog.west-wind.com/posts/2023/Jan/05/Fix-that-damn-Git-Unsafe-Repository
git config --global --add safe.directory "$TEMPDIR"

PROTO="`echo $INPUT_GITEA_SERVER_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
URL=`echo $INPUT_GITEA_SERVER_URL | sed -e s,$PROTO,,g`

git clone "$PROTO$INPUT_TOKEN@$URL/$INPUT_REPOSITORY.wiki.git" "$TEMPDIR"

# Hidden files (like .myfile.txt, .git/, or .gitignore) are NOT copied.
rm -rf "${TEMPDIR:?}"/*
cp -afv "$INPUT_FILEPATH"/* "$TEMPDIR/"

cd "$TEMPDIR"

git config user.name "$INPUT_GIT_USER_NAME"
git config user.email "$INPUT_GIT_USER_EMAIL"

git add -Av
git commit --allow-empty -m "'$INPUT_GIT_COMMIT_MSG'"

git push origin master

echo "wikiUrl=$INPUT_GITEA_SERVER_URL/$INPUT_REPOSITORY/wiki" >> "$GITHUB_OUTPUT"