#!/bin/sh
# Creates a private Forgejo pull mirror for every non-fork, non-archived GitHub repository the token owner has.
# Existing repositories are never modified; a public one is reported for a manual visibility change in Forgejo.
set -eu

github_api=https://api.github.com
github_page_size=100
token_file=/state/forgejo-token
bootstrap_retry_seconds=10

main() {
  until "$0" token > /dev/null; do
    echo "waiting for the Forgejo admin account" >&2
    sleep "$bootstrap_retry_seconds"
  done
  while :; do
    "$0" sync || echo "mirror sync failed" >&2
    sleep "$SYNC_INTERVAL_SECONDS"
  done
}

sync_mirrors() {
  forgejo_token=$(forgejo_token)
  github_login=$(github_api /user | jq -er .login)
  repos=$(github_repos)
  [ -n "$repos" ] || return 0
  echo "$repos" | while read -r repo; do
    mirror_repo "$repo" || echo "failed to mirror $(echo "$repo" | jq -r .name)" >&2
  done
}

forgejo_token() {
  if [ ! -s "$token_file" ]; then
    token_name="forgejo-mirror-$(date +%s)"
    token=$(curl -fsS -u "$FORGEJO_USER:$FORGEJO_PASSWORD" -H 'Content-Type: application/json' \
      -d "{\"name\":\"$token_name\",\"scopes\":[\"write:repository\"]}" \
      "$FORGEJO_URL/api/v1/users/$FORGEJO_USER/tokens" | jq -er .sha1) || return 1
    echo "$token" > "$token_file"
  fi
  cat "$token_file"
}

github_repos() {
  page=1
  while :; do
    batch=$(github_api "/user/repos?affiliation=owner&per_page=$github_page_size&page=$page") || return 1
    echo "$batch" | jq -c '.[] | select((.fork or .archived) | not) | {name, private, clone_url}'
    [ "$(echo "$batch" | jq length)" -lt "$github_page_size" ] && return 0
    page=$((page + 1))
  done
}

mirror_repo() {
  name=$(echo "$1" | jq -r .name)
  repo_path="/repos/$FORGEJO_USER/$name"
  status=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: token $forgejo_token" "$FORGEJO_URL/api/v1$repo_path")
  if [ "$status" = 200 ]; then
    public=$(forgejo_api "$repo_path" | jq -r '.private | not')
    [ "$public" = true ] && echo "$name is public in Forgejo; make it private under Settings" >&2
    return 0
  fi
  [ "$status" = 404 ] || return 1
  body=$(echo "$1" | jq -c --arg owner "$FORGEJO_USER" --arg user "$github_login" --arg token "$GITHUB_TOKEN" '
    {clone_addr: .clone_url, repo_owner: $owner, repo_name: .name, mirror: true, private: true}
    + if .private then {auth_username: $user, auth_password: $token} else {} end')
  forgejo_api /repos/migrate -d "$body" > /dev/null || return 1
  echo "mirrored $name"
}

forgejo_api() {
  path=$1
  shift
  curl -fsS -H "Authorization: token $forgejo_token" -H 'Content-Type: application/json' "$@" "$FORGEJO_URL/api/v1$path"
}

github_api() {
  curl -fsS -H "Authorization: Bearer $GITHUB_TOKEN" -H 'Accept: application/vnd.github+json' "$github_api$1"
}

case "${1:-}" in
  sync) sync_mirrors ;;
  token) forgejo_token ;;
  *) main ;;
esac
