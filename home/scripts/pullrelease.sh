#!/usr/bin/env bash

# Name of the GitHub user or organization
USER="input-output-hk"

# Name of the GitHub repository
REPO="cardano-node"

# GitHub API URL for the releases of the repo
RELEASES_API_URL="https://api.github.com/repos/$USER/$REPO/releases"
TAGS_API_URL="https://api.github.com/repos/$USER/$REPO/git/refs/tags"

# Path to the flake.nix file
FLAKE_NIX_FILE="/home/bismuth/plutus/workspace/vscWs/nix-config.git/intelTower/flake.nix"

# Fetch the list of releases and parse the JSON to get the tag name of the latest release
LATEST_TAG=$(curl -s $RELEASES_API_URL | jq -r '.[0].tag_name')

# Fetch the commit hash associated with the latest tag
COMMIT_HASH=$(curl -s $TAGS_API_URL/$LATEST_TAG | jq -r '.object.sha')

echo "The commit hash of the latest release ($LATEST_TAG) is $COMMIT_HASH"

# Escape COMMIT_HASH for use in sed
ESCAPED_COMMIT_HASH=$(echo $COMMIT_HASH | sed 's/\//\\\//g')

# Find the line with "cardano-node" and replace the commit hash
sed -i.bak "/cardano-node = {/!b;n;s/\(url = \"github:input-output-hk\/cardano-node?rev=\).*\"/\1$ESCAPED_COMMIT_HASH\"/" $FLAKE_NIX_FILE

echo "Updated flake.nix with the latest commit hash."