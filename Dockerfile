ARG ARCH=amd64

FROM --platform=$ARCH node:lts@sha256:64af3819f9275802414d7cdc38c27e9d82bd564dec4d4da87d008255d36c63b4

LABEL description="Node LTS Docker image with common CI tools installed"
LABEL website="https://github.com/rbonestell/docker-node-lts-ci-toolbox"

# Download Google's Linux signing public key into an apt keyring (apt-key is gone in Debian 13)
RUN install -d -m 0755 /etc/apt/keyrings && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google.gpg

# Add Google Chrome for Debian to apt sources
RUN echo "deb [signed-by=/etc/apt/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

# Update apt packages
RUN apt-get update -qqy

# Install common tools with apt
RUN apt-get -y install google-chrome-stable jq gettext-base xvfb procps

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN rm -rf awscliv2.zip
RUN ./aws/install
RUN rm -rf aws

# Upgrade npm to v12 if the bundled npm is older (node:lts Node 24 bundles npm 11)
RUN [ "$(npm -v | cut -d. -f1)" -ge 12 ] || npm install -g npm@12

# Install common tools globally with NPM
RUN npm install -g pick-random-cli

# Clean NPM cache to avoid CI pipelines persisting global cache from this image
RUN npm cache clean --force

# Default entrypoint to bash
ENTRYPOINT ["/bin/bash"]