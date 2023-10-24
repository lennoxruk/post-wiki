#!/bin/bash
set -ex

tempWikiRepoPath=$(mktemp -d)
trap 'rm -rf "$tempWikiRepoPath"' SIGINT SIGTERM ERR EXIT

if [[ -z "$INPUT_WIKI_PATH" ]]; then
  echo "No file path"
  exit 0
fi

if [[ -z "$INPUT_GITEA_SERVER_URL" ]]; then
  echo "No server URL"
  exit 0
fi

git config --global --add safe.directory "$tempWikiRepoPath"

if [[ -n "$INPUT_TOKEN" ]]; then
  protocolPart="`echo $INPUT_GITEA_SERVER_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
  urlPart=`echo $INPUT_GITEA_SERVER_URL | sed -e s,$protocolPart,,g`
  serverUrl=$protocolPart$INPUT_TOKEN@$urlPart
else
  serverUrl=$INPUT_GITEA_SERVER_URL
fi

git clone "$serverUrl/$INPUT_REPOSITORY.wiki.git" "$tempWikiRepoPath"

# clean existing files preserving .git and any hidden files
rm -rf "${tempWikiRepoPath:?}"/*
# copy new files
cp -afv "$INPUT_WIKI_PATH"/* "$tempWikiRepoPath/"

cd "$tempWikiRepoPath"

git config user.name "$INPUT_GIT_USER_NAME"
git config user.email "$INPUT_GIT_USER_EMAIL"

git add -Av
git commit --allow-empty -m "$INPUT_GIT_COMMIT_MSG"

git push origin master

echo "wikiUrl=$INPUT_GITEA_SERVER_URL/$INPUT_REPOSITORY/wiki" >> "$GITHUB_OUTPUT"
