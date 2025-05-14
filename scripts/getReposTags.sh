#!/bin/bash

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <github_owner> <topic>"
    exit 1
fi

OWNER="$1"
TOPIC="$2"

# Check gh and jq
command -v gh >/dev/null 2>&1 || { echo >&2 "'gh' is required. Install GitHub CLI."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "'jq' is required. Install: sudo apt install jq"; exit 1; }

# Get repos
echo "Search repos with topic='$TOPIC' in '$OWNER'..."
REPOS_JSON=$(gh search repos --owner "$OWNER" --topic "$TOPIC" --json name,owner --limit 100)

REPO_LIST=$(echo "$REPOS_JSON" | jq -r '.[] | "\(.owner.login)/\(.name)"')

if [ -z "$REPO_LIST" ]; then
    echo "Repositories are not found"
    exit 0
fi

# Get tags
for REPO in $REPO_LIST; do
    echo "-- Repo: $REPO"
    TAGS=$(gh api "repos/$REPO/tags" --paginate --jq '.[].name')

    if [ -z "$TAGS" ]; then
        echo "  (there are no tags)"
    else
        echo "$TAGS" | sed 's/^/  - /'
    fi
    echo
done
