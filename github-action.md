name: Build and Deploy Next.js

on:
  push:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Get SHA
        id: vars
        run: echo "sha_short=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT

      - name: Build & Push Docker Image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: dukaan/nextjs-app:${{ steps.vars.outputs.sha_short }}

      - name: Update manifest image tag
        uses: jacobtomlinson/gha-find-replace@v3
        with:
          find: "dukaan/nextjs-app:latest"
          replace: "dukaan/nextjs-app:${{ steps.vars.outputs.sha_short }}"
          include: "deployment/**"
          regex: false

      - name: Push to infra repo
        uses: dnmemec/copy/file_to_another_repo_action@master
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
          source_file: deployment/nextjs-app.yaml
          destination_repo: TeamDukaan/infra
          destination_branch: master
          destination_folder: edge/nextjs-app/
          user_email: your@email.com
          user_name: yourname
          commit_message: "nextjs deploy update"