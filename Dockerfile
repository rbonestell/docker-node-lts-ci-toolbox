ARG ARCH=amd64

FROM --platform=$ARCH node:lts@sha256:22f6fe5f59fb7fed238b19623506d573dffaa932ce33b84ce541a9a2e0eade28

LABEL description="Node LTS Docker image with common CI tools installed"
LABEL website="https://github.com/rbonestell/docker-node-lts-ci-toolbox"

# Download Google's Linux signing public key and add to apt
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

# Add Google Chrome for Debian to apt sources
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

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

# Upgrade npm to v12+ (node:lts bundles npm 11)
RUN npm install -g npm@12

# Install common tools globally with NPM
RUN npm install -g pick-random-cli

# Clean NPM cache to avoid CI pipelines persisting global cache from this image
RUN npm cache clean --force

# Default entrypoint to bash
ENTRYPOINT ["/bin/bash"]