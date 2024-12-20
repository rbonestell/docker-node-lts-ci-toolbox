# Node LTS + Common CI Tools

A low maintenance Docker image based upon Node.js LTS, intended for CI/CD pipelines and automated testing workflows.

## Overview

This image extends the official `node:lts` base image and adds several convenient tools commonly used in CI pipelines:

- gettext-base
- google-chrome-stable
- jq
- pick-random-cli
- procps
- random-generator-cli
- xvfb

> [!IMPORTANT]  
> The `google-chrome-stable` package is not available for ARM architectures, so the default `ARCH` argument value is set to `amd64`.
