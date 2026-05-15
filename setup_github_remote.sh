#!/bin/bash
# Setup GitHub remote and push audit-log
# Usage: ./setup_github_remote.sh <github_username> <token_or_ssh>
# Example: ./setup_github_remote.sh myuser ghp_xxxx
# Or with SSH: ./setup_github_remote.sh myuser ssh

GITHUB_USER="${1:-agentrisk-audit}"
AUTH_METHOD="${2:-ssh}"

cd /home/admin/agent-score-project/audit-log

if [ "$AUTH_METHOD" = "ssh" ]; then
    REMOTE_URL="git@github.com:${GITHUB_USER}/audit-log.git"
else
    REMOTE_URL="https://${GITHUB_USER}:${AUTH_METHOD}@github.com/${GITHUB_USER}/audit-log.git"
fi

# Set remote
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"

# Push
git push -u origin main

echo "✅ Successfully pushed audit-log to https://github.com/${GITHUB_USER}/audit-log"
