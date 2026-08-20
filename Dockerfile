ARG ARCH=amd64

FROM --platform=$ARCH node:lts@sha256:934240a162082fd8b8a2f90cd5114446443f1eba1c5378f6687167ca405e6584

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

# Install common tools globally with NPM
RUN npm install -g nanoid pick-random-cli

# Clean NPM cache to avoid CI pipelines persisting global cache from this image
RUN npm cache clean --force

# Default entrypoint to bash
ENTRYPOINT ["/bin/bash"]