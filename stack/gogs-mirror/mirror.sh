#!/bin/sh
# Creates a private Gogs pull mirror for every non-fork, non-archived GitHub repository the token owner has.
# Existing repositories are never modified; a public one is reported for a manual visibility change in Gogs.
set -eu

github_api=https://api.github.com
github_page_size=100
token_file=/state/gogs-token

main() {
  while :; do
    "$0" sync || echo "mirror sync failed" >&2
    sleep "$SYNC_INTERVAL_SECONDS"
  done
}

sync_mirrors() {
  gogs_token=$(gogs_token)
  gogs_uid=$(gogs_api /user | jq -r .id)
  github_login=$(github_api /user | jq -r .login)
  github_repos | while read -r repo; do
    mirror_repo "$repo" || echo "failed to mirror $(echo "$repo" | jq -r .name)" >&2
  done
}

gogs_token() {
  if [ ! -s "$token_file" ]; then
    token_name="gogs-mirror-$(date +%s)"
    curl -fsS -u "$GOGS_USER:$GOGS_PASSWORD" -H 'Content-Type: application/json' \
      -d "{\"name\":\"$token_name\"}" "$GOGS_URL/api/v1/users/$GOGS_USER/tokens" | jq -r .sha1 > "$token_file"
  fi
  cat "$token_file"
}

github_repos() {
  page=1
  while :; do
    batch=$(github_api "/user/repos?affiliation=owner&per_page=$github_page_size&page=$page")
    echo "$batch" | jq -c '.[] | select((.fork or .archived) | not) | {name, private, clone_url}'
    [ "$(echo "$batch" | jq length)" -lt "$github_page_size" ] && return 0
    page=$((page + 1))
  done
}

mirror_repo() {
  name=$(echo "$1" | jq -r .name)
  repo_path="/repos/$GOGS_USER/$name"
  status=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: token $gogs_token" "$GOGS_URL/api/v1$repo_path")
  if [ "$status" = 200 ]; then
    public=$(gogs_api "$repo_path" | jq -r '.private | not')
    [ "$public" = true ] && echo "$name is public in Gogs; make it private under Settings" >&2
    return 0
  fi
  [ "$status" = 404 ] || return 1
  body=$(echo "$1" | jq -c --argjson uid "$gogs_uid" --arg user "$github_login" --arg token "$GITHUB_TOKEN" '
    {clone_addr: .clone_url, uid: $uid, repo_name: .name, mirror: true, private: true}
    + if .private then {auth_username: $user, auth_password: $token} else {} end')
  gogs_api /repos/migrate -d "$body" > /dev/null || return 1
  echo "mirrored $name"
}

gogs_api() {
  path=$1
  shift
  curl -fsS -H "Authorization: token $gogs_token" -H 'Content-Type: application/json' "$@" "$GOGS_URL/api/v1$path"
}

github_api() {
  curl -fsS -H "Authorization: Bearer $GITHUB_TOKEN" -H 'Accept: application/vnd.github+json' "$github_api$1"
}

if [ "${1:-}" = sync ]; then
  sync_mirrors
else
  main
fi
