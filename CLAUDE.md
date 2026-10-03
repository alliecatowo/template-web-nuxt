# CLAUDE.md

Guidance for AI agents (and humans) working in the **template-web-nuxt** repo.

## What template-web-nuxt is

Nuxt app template with CI, Firebase and docs. A Nuxt 4 app with `@nuxt/ui` (Tailwind 4), statically generated and hosted on Firebase Hosting.

## Commands

`mise trust && mise install` once per clone, then `mise run install`. **pnpm only**: never npm or yarn, never a second lockfile. `mise` puts `node_modules/.bin` on PATH and loads `.env`, so run tools bare (`nuxt`, `eslint`, `prettier`, `vitest`).

- `mise run check`: `eslint .` + `prettier --check .` + `nuxt typecheck`. **Must be clean before committing.** `mise run fmt` fixes.
- `mise run test`: vitest (`tests/`). **Must be green.**
- `mise run build`: `nuxt generate` into `.output/public` (what Firebase serves).
- `pnpm dev`: dev server on :3000.

CI and deploy run the same tasks.

## Architecture

- `app/`: Nuxt 4 srcDir. `pages/` file-based routes, `utils/` auto-imported helpers, `assets/css/main.css` imports Tailwind and Nuxt UI.
- `nuxt.config.ts`: modules (`@nuxt/ui`, `@nuxt/eslint`). `eslint.config.mjs` extends the generated `.nuxt/eslint.config.mjs`.
- `firebase.json` / `.firebaserc`: static hosting config. `.github/workflows/deploy.yml`: PR previews and live deploy.

## Conventions that bite

- **Linting is `@nuxt/eslint`; formatting is Prettier.** Biome's Vue support formats only the `<script>` block, not `<template>`, so it is not used here. ESLint stylistic rules stay off so the two do not fight.
- **TypeScript is pinned to 6.0.x on purpose.** typescript-eslint (under `@nuxt/eslint`) supports `<6.1` and throws on TypeScript 7. Dependabot ignores the TS major; move to 7 once typescript-eslint supports it.
- Wrap the app in `<UApp>` (done in `app/app.vue`) or Nuxt UI overlays/toasts will not work.
- `nuxt prepare` runs on `postinstall` and generates `.nuxt/` (types and the ESLint config); `eslint` and `typecheck` fail until it has run.
- pnpm skips dependency build scripts: allow new ones in `pnpm-workspace.yaml` (`allowBuilds`).

## Things that bit us

- (none yet)

## Deploying

Set the Firebase project id in `.firebaserc` and `deploy.yml`, run `firebase init hosting:github` once for the `FIREBASE_SERVICE_ACCOUNT` secret. Without the secret the deploy steps are skipped. Don't change secrets or deploy by hand unless asked.

## Changelog

`CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com). Every user-facing change adds a bullet under `## [Unreleased]` in the same change as the code.

## Git workflow

- Branch off `main`. Conventional commits (commitlint via lefthook). PRs are draft by default.
- **Worktrees go in `.claude/worktrees/<branch-with-dashes>` inside this repo.** Never under `/tmp` or a scratchpad, and never run installs or builds there. Remove after merge.
- Dependabot patch/minor PRs auto-merge on green; major bumps need a human.

## Docs site

`docs/` is a VitePress site and its own pnpm root (`cd docs && pnpm install && pnpm dev`; build with `pnpm build`). `.github/workflows/docs.yml` deploys it to GitHub Pages on pushes to `main` that touch `docs/`. The base path is `/template-web-nuxt/`; set `DOCS_BASE=/` when it moves to a custom domain. A dead link fails the build, so link repo files via github.com URLs.
