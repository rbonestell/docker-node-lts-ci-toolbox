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
   pick-random-cli). Nothing is committed if this fails, so the next run retries. A failure
   after the merge in step 3 is not retried automatically; re-run the failed jobs.
3. Commits the bump to a branch, opens a PR, reports the build above as the required
   `build-and-test` check, and squash merges it. PRs opened with `GITHUB_TOKEN` don't trigger
   PR Validation, which is why the workflow reports the check itself.
4. Creates a release whose version is the previous release with its revision number
   incremented (for example `v1.0.0` becomes `v1.0.1`).
5. Calls **Release Deploy** to build and push the new image tags to Docker Hub. It is called
   directly because releases created with `GITHUB_TOKEN` do not trigger the `release` event.

Because it tracks `node:lts`, the image moves to a new Node major version automatically when
that version becomes LTS.

Manual releases are unaffected: publish a release tagged `vX.Y.Z` and Release Deploy builds
and pushes the image with that version.

### Repository requirements

- **Allow GitHub Actions to create and approve pull requests** must be enabled
  (Settings → Actions → General → Workflow permissions).
- The `main` ruleset may require PRs and the `build-and-test` check, but must not require
  approving reviews, since the workflow merges its own PR.
- The `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` Actions secrets must be set.
