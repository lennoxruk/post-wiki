#!/bin/bash
set -ex

tempWikiRepoPath=$(mktemp -d)
trap 'rm -rf "$tempWikiRepoPath"' SIGINT SIGTERM ERR EXIT

[ -z "${INPUT_WIKI_PATH}" ] && echo 'No wiki file path given' && exit 1
[ -z "${INPUT_GITEA_SERVER_URL}" ] && echo 'No server URL' && exit 1

git config --global --add safe.directory "${tempWikiRepoPath}"

if [[ -n "$INPUT_TOKEN" ]]; then
  protocolPart="$(echo $INPUT_GITEA_SERVER_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g')"
  urlPart=$(echo $INPUT_GITEA_SERVER_URL | sed -e s,$protocolPart,,g)
  serverUrl=$protocolPart$INPUT_TOKEN@$urlPart
else
  serverUrl=$INPUT_GITEA_SERVER_URL
fi

git clone "$serverUrl/$INPUT_REPOSITORY.wiki.git" "$tempWikiRepoPath"

# clean existing files preserving .git folder and any hidden files
rm -rf "${tempWikiRepoPath:?}"/*

# copy files to wiki repository
cp -afv "$INPUT_WIKI_PATH"/* "$tempWikiRepoPath/"

cd "$tempWikiRepoPath"

git config user.name "$INPUT_GIT_USER_NAME"
git config user.email "$INPUT_GIT_USER_EMAIL"

readonly branchName=$(git rev-parse --abbrev-ref HEAD)

case "${branchName-}" in
master | main)
  echo "Branch is $branchName"
  ;;
*)
  echo "Invalid branch, must be main or master"
  exit 1
  ;;
esac

[ "${INPUT_REMOVE_HISTORY-}" = 'true' ] && git checkout --orphan clean_branch && forcePush='-f' || forcePush=

git add -Av
git commit --allow-empty -m "${INPUT_GIT_COMMIT_MSG}"

if [ "${INPUT_REMOVE_HISTORY-}" = 'true' ]; then
  # delete default branch
  git branch -D "${branchName}"
  # rename current branch to default
  git branch -m "${branchName}"
fi

git push ${forcePush} origin "${branchName}"
