#!/usr/bin/env bash
# Publish a verified Creator screenshot bundle as an exact-replacement docs PR.

set -euo pipefail

bundle="${1:?bundle directory is required}"
docs="${2:?documentation checkout is required}"
branch="automation/usb-creator-screenshots"

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "DOCS_REPO_TOKEN is required for trusted docs publication" >&2
  exit 1
fi

bundle="$(cd "$bundle" && pwd)"
docs="$(cd "$docs" && pwd)"

git -C "$docs" switch -C "$branch" origin/main
(cd "$docs" && node scripts/import-usb-creator-flow.mjs "$bundle")

if [[ -z "$(git -C "$docs" status --porcelain -- static/img/unraid-os/getting-started/create-unraid-usb)" ]]; then
  echo "USB Creator documentation screenshots are unchanged"
  exit 0
fi

git -C "$docs" config user.name "unraid-docs-automation"
git -C "$docs" config user.email "actions@users.noreply.github.com"
git -C "$docs" add -- static/img/unraid-os/getting-started/create-unraid-usb
git -C "$docs" commit -m "docs: refresh USB Creator setup screenshots"

remote_sha="$(git -C "$docs" ls-remote origin "refs/heads/$branch" | cut -f1)"
if [[ -n "$remote_sha" ]]; then
  git -C "$docs" push --force-with-lease="refs/heads/$branch:$remote_sha" origin "HEAD:refs/heads/$branch"
else
  git -C "$docs" push origin "HEAD:refs/heads/$branch"
fi

if gh pr view "$branch" --repo unraid/docs >/dev/null 2>&1; then
  gh pr edit "$branch" --repo unraid/docs \
    --body "Automated refresh from the passing USB Creator journey ${USB_CREATOR_CAPTURE_ID}. Every image was accepted only after the full virtual USB write and filesystem verification passed, and the docs importer revalidated each SHA-256 digest."
else
  gh pr create --repo unraid/docs --head "$branch" --base main \
    --title "docs: refresh USB Creator setup screenshots" \
    --body "Automated refresh from the passing USB Creator journey ${USB_CREATOR_CAPTURE_ID}. Every image was accepted only after the full virtual USB write and filesystem verification passed, and the docs importer revalidated each SHA-256 digest."
fi
