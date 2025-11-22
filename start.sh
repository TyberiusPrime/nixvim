#!/usr/bin/env bash
set -euo pipefail
git add .
nix build
# pop first argument
XDG_DATA_HOME=./XDG/data XDG_STATE_HOME=./XDG/state XDG_CONFIG_HOME=./XDG/config ./result/bin/nvim $@
