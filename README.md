# Node LTS + Common CI Tools

A low maintenance Docker image based upon Node.js LTS, intended for CI/CD pipelines and automated testing workflows.

## Overview

This image extends the official `node:lts` base image (currently Node.js 24) with npm upgraded
to v12, and adds several convenient tools commonly used in CI pipelines:

- gettext-base
- google-chrome-stable
- jq
- pick-random-cli
- procps
- xvfb

> [!NOTE]
> `random-generator-cli` was unpublished from npm in May 2025 and has been removed from
> this image. Use [`pick-random-cli`](https://www.npmjs.com/package/pick-random-cli) for
> random selection.

> [!IMPORTANT]  
> The `google-chrome-stable` package is not available for ARM architectures, so the default `ARCH` argument value is set to `amd64`.

## Automated base image updates

The `node:lts` base image is pinned by digest in the `Dockerfile`. The **Node LTS Update**
workflow (`.github/workflows/node-lts-update.yml`) keeps that pin current with no manual steps.
It runs daily and can also be started manually with `workflow_dispatch`:

1. Compares the currently published `node:lts` digest to the one pinned in the `Dockerfile`,
   and stops if they match.
2. Updates the pin, builds the image and smoke tests it (Node, npm 12+, jq, AWS CLI, Chrome,
   pick-random-cli). Nothing is merged if this fails, so the next run retries. A failure
   after the merge in step 3 is not retried automatically; run Release Deploy manually.
3. Commits the bump to a branch, opens a PR, reports the build above as the required
   `build-and-test` check, and squash merges it. PRs opened with `GITHUB_TOKEN` don't trigger
   PR Validation, which is why the workflow reports the check itself.
4. Calls **Release Deploy** for the merge commit, which builds and pushes the image to Docker
   Hub and then creates the release with the next version. It is called directly because
   releases created with `GITHUB_TOKEN` do not trigger the `release` event.

Because it tracks `node:lts`, the image moves to a new Node major version automatically when
that version becomes LTS.

## Versioning

Releases use calendar versions in the form `vYYYY.MM.DD.I` (UTC date), where `I` is the
release number for that day, starting at `1`. For example, the first release on 2 October
2026 is `v2026.10.02.1` and a second one that day is `v2026.10.02.2`. Git tags and GitHub
releases have the `v` prefix; Docker image tags don't (`2026.10.02.1`).

Each image is pushed to Docker Hub as `latest`, `<version>`, `<short sha>` and
`<version>-<short sha>`.

### Manual releases

- **Run workflow** on **Release Deploy** (recommended): creates the next version's release from
  `main` with generated notes, then builds and pushes it.
- **Publish a release** on GitHub: Release Deploy builds and pushes it. If the release's tag
  isn't the next `vYYYY.MM.DD.I` version, that version's tag is also added to the same commit,
  and the image is tagged with it.

## Repository requirements

- **Allow GitHub Actions to create and approve pull requests** must be enabled
  (Settings → Actions → General → Workflow permissions).
- The `main` ruleset may require PRs and the `build-and-test` check, but must not require
  approving reviews, since the workflow merges its own PR.
- The `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` Actions secrets must be set.
