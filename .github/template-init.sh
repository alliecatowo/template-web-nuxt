#!/usr/bin/env bash
# One-time rename for a repo created from this template. Run by template-init.yml; it
# deletes itself and its workflow when done. Values to replace live in .github/template.env.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if [[ ! -f .github/template.env ]]; then echo "already initialised"; exit 0; fi
# shellcheck disable=SC1091
. .github/template.env # OLD_NAME OLD_SNAKE OLD_DESC OLD_YEAR OLD_STACK_LABEL

new_name="$(printf '%s' "${REPO_NAME:?}" | tr 'A-Z_.' 'a-z--')"
if [[ ! "$new_name" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "::error::repo name '$REPO_NAME' must be letters, digits and hyphens, starting with a letter"
  exit 1
fi
if [[ "$new_name" == "$OLD_NAME" ]]; then echo "still the template repo; nothing to do"; exit 0; fi

# Descriptions land inside JSON, TOML and Markdown, so keep them to one plain line.
new_desc="$(printf '%s' "${REPO_DESC:-}" | tr -d '\r\n\\' | tr '"' "'" | sed 's/^ *//;s/ *$//')"
[[ -n "$new_desc" ]] || new_desc="A new $OLD_STACK_LABEL project."

export OLD_NAME OLD_SNAKE OLD_DESC OLD_YEAR
export NEW_NAME="$new_name" NEW_SNAKE="${new_name//-/_}" NEW_DESC="$new_desc" NEW_YEAR="$(date +%Y)"

# Text files only. Lockfiles are rewritten consistently, so frozen installs keep working.
git ls-files -z -- . ':!.github/workflows' | xargs -0 -r grep -IlZF -e "$OLD_NAME" -e "$OLD_SNAKE" -e "$OLD_DESC" -e "(c) $OLD_YEAR" \
  | xargs -0 -r perl -pi -e '
      s/\Q$ENV{OLD_DESC}\E/$ENV{NEW_DESC}/g;
      s/\Q$ENV{OLD_SNAKE}\E/$ENV{NEW_SNAKE}/g;
      s/\Q$ENV{OLD_NAME}\E/$ENV{NEW_NAME}/g;
      s/\(c\) \Q$ENV{OLD_YEAR}\E/(c) $ENV{NEW_YEAR}/g;' || true

# Paths named after the project (crates/<name>-cli, src/<snake_name>, ...), deepest first.
find . -depth \( -name "*$OLD_NAME*" -o -name "*$OLD_SNAKE*" \) -not -path './.git/*' | while IFS= read -r p; do
  base="$(basename "$p")"; base="${base//$OLD_SNAKE/$NEW_SNAKE}"; base="${base//$OLD_NAME/$NEW_NAME}"
  mv "$p" "$(dirname "$p")/$base"
done

has_docs=0; [[ -f .github/workflows/docs.yml ]] && has_docs=1

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git rm -q -f .github/template.env .github/template-init.sh
git add -A

commit_and_push() {
  git commit -q -m "chore: initialise from template ($OLD_NAME -> $NEW_NAME)" -m "Renames the template placeholders and removes the one-time init workflow."
  if [[ "${INIT_NO_PUSH:-}" == 1 ]]; then return 0; fi
  git push origin HEAD:main
}

# GITHUB_TOKEN may not be allowed to delete a workflow file; if so keep it (it is inert
# once template.env is gone) rather than fail.
git rm -q -f .github/workflows/template-init.yml
if ! commit_and_push; then
  echo "::warning::could not delete the init workflow with GITHUB_TOKEN; keeping it (inert)"
  git reset -q --soft HEAD~1
  git restore --staged --worktree .github/workflows/template-init.yml 2>/dev/null || git checkout HEAD -- .github/workflows/template-init.yml
  git add -A
  commit_and_push
fi

if [[ "${INIT_NO_PUSH:-}" == 1 ]]; then exit 0; fi

# Pushes made with GITHUB_TOKEN do not trigger workflows, so start CI (and the docs
# deploy, if Pages can be enabled) explicitly on the initialised commit.
if [[ $has_docs -eq 1 ]]; then
  gh api -X POST "repos/$GITHUB_REPOSITORY/pages" -f build_type=workflow >/dev/null 2>&1 || true
  gh workflow run docs.yml --ref main || true
fi
gh workflow run ci.yml --ref main || true
