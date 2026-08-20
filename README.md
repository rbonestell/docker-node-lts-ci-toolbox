# Node LTS + Common CI Tools

A low maintenance Docker image based upon Node.js LTS, intended for CI/CD pipelines and automated testing workflows.

## Overview

This image extends the official `node:lts` base image and adds several convenient tools commonly used in CI pipelines:

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

The `node:lts` base image is pinned by digest in the `Dockerfile`, and the update of that
pin is fully automated:

1. **Dependabot** (`.github/dependabot.yml`) checks the `node:lts` tag daily and opens a PR
   bumping the pinned digest whenever a new Node LTS image is published.
2. **PR Validation** builds the image on that PR.
3. **Dependabot Auto Merge** enables auto-merge on the PR, so it squash merges as soon as
   validation passes.
4. **Dependabot Auto Release** creates a new release once the merged PR touched the
   `Dockerfile`. The version is the previous release with its revision number incremented
   (for example `v1.0.0` becomes `v1.0.1`).
5. **Release Deploy** builds and pushes the new image tags to Docker Hub. It is called
   directly by the auto release workflow, because releases created with `GITHUB_TOKEN` do
   not trigger the `release` event; manually published releases still run it as before.

Manual releases are unaffected: publish a release tagged `vX.Y.Z` and the image is built
and pushed with that version.

### Repository requirements

- Allow auto-merge must be enabled in the repository settings for step 3.
- Allow GitHub Actions to create and approve pull requests / branch protection should permit
  the `GITHUB_TOKEN` to merge; required status checks on `main` gate the auto-merge.
- The `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets must be available to Dependabot's
  merged changes via the normal Actions secrets (they are only used after merge, on `main`).
