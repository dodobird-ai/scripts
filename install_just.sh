#!/bin/bash
set -e
set -o errexit; set -o pipefail; set -o nounset;


# INSTALL
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# SETUP

# Create directory for completion scripts
mkdir -p /etc/bash_completion.d/

# Generate and save the completion script
just --completions bash > /etc/bash_completion.d/just

source /etc/bash_completion.d/just
