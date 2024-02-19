# Post Wiki Action

![version](version.svg)

Gitea action to publish and replace files in a Gitea repository wiki. Purpose of writing is for auto posting/generation of a documentation wiki in a workflow.

This action can only manipulate the wiki of the Gitea repository from which it is been run. The wiki must exist before this action is executed.

## How to use

This action deploys the content found in the specified `wikiPath` to the Gitea repository's wiki. `wiki` is the default path if not specified. All existing wiki content is replaced.

### Example 1

This will post all files found in the repository's wiki folder. The commit will be from user/email: _wiki.bot/wiki.bot@noreply.com_

```yaml
on:
  push:
    branches:
      - main

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo code
        uses: actions/checkout@v4

      #- name: DO SOME TASK TO GENERATE THE WIKI FILES

      - name: Invoke post-wiki action
        id: postWiki
        uses: lennoxruk/post-wiki@v1.5

      - name: Show wiki url
        run: echo '🍏 Wiki URL is ${{ steps.postWiki.outputs.wikiUrl }}'
```

### Example 2

This will post all files found in the repository's docs folder. The commit will be from user/email: _test/test@noreply.com_ and commit message will be _auto publish test_.

```yaml
on:
  push:
    branches:
      - main

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo code
        uses: actions/checkout@v4

      - name: Some task to generate wiki file
        run: |
          mkdir docs
          echo "Hello" | tee docs/Hello.md

      - name: Invoke post-wiki action
        id: postWiki
        uses: lennoxruk/post-wiki@v1.5
        with:
          wikiPath: docs
          userName: test
          userEmail: test@noreply.com
          commitMessage: auto publish test

      - name: Show wiki url
        run: echo '🍏 Wiki URL is ${{ steps.postWiki.outputs.wikiUrl }}'
```
<!-- action-docs-inputs -->
## Inputs

| parameter     | description                                                 | required | default                |
|---------------|-------------------------------------------------------------|----------|------------------------|
| wikiPath      | Path of the folder containing the wiki files to be deployed | `false`  | wiki                   |
| userName      | Git user name of wiki commit                                | `false`  | wiki.bot               |
| userEmail     | Git user email of wiki commit                               | `false`  | `wiki.bot@noreply.com` |
| commitMessage | Wiki repository commit message                              | `false`  | Auto Publish Wiki      |
| removeHistory | Remove wiki history                                         | `false`  | false                  |
<!-- action-docs-inputs -->
<!-- action-docs-outputs -->
## Outputs

| parameter | description                |
|-----------|----------------------------|
| wikiUrl   | URL of the repository wiki |
<!-- action-docs-outputs -->

## Background

Many thanks to the author of the [deploy-wiki](https://github.com/actions4gh/deploy-wiki) Github action, which provided direction for this Gitea action.

The general logic of the original action was preserved but needed a way of authenticating access to the Gitea wiki repository as the Github method does not work with Gitea. Through experimentation, I found that the token available in the act runner, `${{ github.token }}`, provided a temporary token to access the repository and the wiki repository. This token is inserted into the wiki URL for authenticated read/write access to the wiki repository.

Reduced the original functionality so the action can only change the wiki of the repository from which the action is run. Reason is to reduce the security issues of providing input tokens which allow access to different repositories.
