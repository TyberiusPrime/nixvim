#/usr/bin/env bash
jj git fetch && jj rebase -d main && nix build
