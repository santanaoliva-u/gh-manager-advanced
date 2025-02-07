#!/bin/bash

# File: gh-manager.sh
# GitHub Manager Advanced - Enhanced GitHub CLI for repositories, issues, PRs, keys, and more.

set -euo pipefail # Robust error handling

# Validar que haya al menos un argumento
if [[ $# -eq 0 ]]; then
  echo "❌ ERROR: No se proporcionaron argumentos."
  echo "Uso: gh-manager <repo|issue|pr|keys|gists|user|status|events> <command> [options]"
  exit 1
fi

BASE_URL="https://api.github.com"
LOG_FILE="$HOME/.gh-manager.log"
TOKEN="${GITHUB_TOKEN:-}"
DEFAULT_BRANCH="main" # Default branch for PRs

# Ensure required tools are available
REQUIRED_TOOLS=(curl jq notify-send ssh-add gpg)
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "❌ ERROR: Required tool '$tool' is not installed."
    exit 1
  fi
done

# Logging utilities
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] - $2" >>"$LOG_FILE"; }
info() { log "INFO" "$1"; }
error() { log "ERROR" "$1"; }

# Notifications
notify() { command -v notify-send &>/dev/null && notify-send "GitHub Manager" "$1"; }

# Ensure token is provided
if [[ -z "$TOKEN" ]]; then
  error "No GitHub token found. Set GITHUB_TOKEN environment variable."
  echo "❌ ERROR: No GitHub token provided. Set GITHUB_TOKEN."
  exit 1
fi

# Core Functions
# ----------------------
gh_create_repo() {
  local repo_name="$1"
  info "Creating repository: $repo_name"
  curl -s -X POST -H "Authorization: token $TOKEN" \
    -d "{\"name\":\"$repo_name\"}" \
    "$BASE_URL/user/repos" || {
    error "Failed to create repository $repo_name."
    exit 1
  }
  notify "Repository $repo_name created successfully."
}

gh_list_repos() {
  info "Listing repositories"
  curl -s -H "Authorization: token $TOKEN" "$BASE_URL/user/repos" | jq '.[].name'
}

gh_delete_repo() {
  local repo_name="$1"
  info "Deleting repository: $repo_name"
  curl -s -X DELETE -H "Authorization: token $TOKEN" \
    "$BASE_URL/repos/$GITHUB_USER/$repo_name" || {
    error "Failed to delete repository $repo_name."
    exit 1
  }
  notify "Repository $repo_name deleted successfully."
}

gh_list_issues() {
  local repo="$1"
  info "Listing issues for repository: $repo"
  curl -s -H "Authorization: token $TOKEN" "$BASE_URL/repos/$repo/issues" | jq '.[] | {title: .title, state: .state}'
}

gh_create_pr() {
  local repo="$1" title="$2" body="$3" branch="${4:-$DEFAULT_BRANCH}"
  info "Creating pull request in $repo: $title"
  curl -s -X POST -H "Authorization: token $TOKEN" \
    -d "{\"title\":\"$title\", \"body\":\"$body\", \"head\":\"$branch\", \"base\":\"$DEFAULT_BRANCH\"}" \
    "$BASE_URL/repos/$repo/pulls" || {
    error "Failed to create pull request $title in $repo."
    exit 1
  }
  notify "Pull request '$title' created in $repo."
}

gh_list_prs() {
  local repo="$1"
  info "Listing open pull requests for repository: $repo"
  curl -s -H "Authorization: token $TOKEN" "$BASE_URL/repos/$repo/pulls" | jq '.[] | {title: .title, state: .state}'
}

gh_keys_list() {
  info "Listing SSH and GPG keys"
  curl -s -H "Authorization: token $TOKEN" "$BASE_URL/user/keys" | jq '.[] | {id: .id, title: .title}'
}

gh_keys_add_ssh() {
  local key_path="$1"
  info "Adding SSH key from $key_path"
  curl -s -X POST -H "Authorization: token $TOKEN" \
    -d "{\"title\":\"$(hostname)\", \"key\":\"$(cat "$key_path")\"}" \
    "$BASE_URL/user/keys" || {
    error "Failed to add SSH key from $key_path."
    exit 1
  }
  notify "SSH key added successfully."
}

gh_keys_add_gpg() {
  local gpg_key="$1"
  info "Adding GPG key: $gpg_key"
  curl -s -X POST -H "Authorization: token $TOKEN" \
    -d "{\"armored_public_key\":\"$gpg_key\"}" \
    "$BASE_URL/user/gpg_keys" || {
    error "Failed to add GPG key."
    exit 1
  }
  notify "GPG key added successfully."
}

gh_gists_create() {
  local description="$1" visibility="$2" file="$3" content="$4"
  info "Creating Gist: $description"
  curl -s -X POST -H "Authorization: token $TOKEN" \
    -d "{\"description\":\"$description\", \"public\":$([[ "$visibility" == "public" ]] && echo true || echo false), \"files\":{\"$file\":{\"content\":\"$content\"}}}" \
    "$BASE_URL/gists" || {
    error "Failed to create Gist."
    exit 1
  }
  notify "Gist created successfully."
}

gh_status() {
  info "Checking GitHub API status"
  curl -s "$BASE_URL" || {
    error "GitHub API is unreachable."
    exit 1
  }
  notify "GitHub API is online."
}

gh_events_list() {
  info "Listing recent user events"
  curl -s -H "Authorization: token $TOKEN" "$BASE_URL/users/$GITHUB_USER/events" | jq '.[] | {type: .type, repo: .repo.name}'
}

# User Management
gh_user_block() {
  local user="$1"
  info "Blocking user: $user"
  curl -s -X PUT -H "Authorization: token $TOKEN" \
    "$BASE_URL/user/blocks/$user" || {
    error "Failed to block user $user."
    exit 1
  }
  notify "User $user blocked successfully."
}

gh_user_unblock() {
  local user="$1"
  info "Unblocking user: $user"
  curl -s -X DELETE -H "Authorization: token $TOKEN" \
    "$BASE_URL/user/blocks/$user" || {
    error "Failed to unblock user $user."
    exit 1
  }
  notify "User $user unblocked successfully."
}

gh_user_followers() {
  info "Listing user followers"
  curl -s -H "Authorization: token $TOKEN" "$BASE_URL/user/followers" | jq '.[].login'
}

# Main Menu
case "$1" in
repo)
  case "$2" in
  create) gh_create_repo "$3" ;;
  list) gh_list_repos ;;
  delete) gh_delete_repo "$3" ;;
  *) echo "Usage: $0 repo <create|list|delete> [name]" ;;
  esac
  ;;
issue)
  case "$2" in
  create) gh_create_issue "$3" "$4" "$5" ;;
  list) gh_list_issues "$3" ;;
  *) echo "Usage: $0 issue <create|list> <repo> [options]" ;;
  esac
  ;;
pr)
  case "$2" in
  create) gh_create_pr "$3" "$4" "$5" "$6" ;;
  list) gh_list_prs "$3" ;;
  *) echo "Usage: $0 pr <create|list> <repo> [options]" ;;
  esac
  ;;
keys)
  case "$2" in
  list) gh_keys_list ;;
  add-ssh) gh_keys_add_ssh "$3" ;;
  add-gpg) gh_keys_add_gpg "$3" ;;
  *) echo "Usage: $0 keys <list|add-ssh|add-gpg> [options]" ;;
  esac
  ;;
gists)
  case "$2" in
  create) gh_gists_create "$3" "$4" "$5" "$6" ;;
  *) echo "Usage: $0 gists <create> [options]" ;;
  esac
  ;;
user)
  case "$2" in
  block) gh_user_block "$3" ;;
  unblock) gh_user_unblock "$3" ;;
  followers) gh_user_followers ;;
  *) echo "Usage: $0 user <block|unblock|followers> [options]" ;;
  esac
  ;;
status) gh_status ;;
events) gh_events_list ;;
*)
  echo "Usage: $0 <repo|issue|pr|keys|gists|user|status|events> <command> [options]"
  ;;
esac
