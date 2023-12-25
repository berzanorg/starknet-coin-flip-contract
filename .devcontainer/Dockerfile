FROM debian:bookworm

RUN apt update

RUN apt install -y \
    git \
    curl

# Set shell.
ENV SHELL=/bin/bash

# Install Scarb v2.3.1 (because v2.4.0 isn't supported on Mainnet yet).
RUN curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v 2.3.1

# Install Starkli.
RUN curl https://get.starkli.sh | sh  &&  /root/.starkli/bin/starkliup 
