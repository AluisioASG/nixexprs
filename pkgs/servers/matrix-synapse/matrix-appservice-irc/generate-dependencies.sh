#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --nodejs-12 \
  --input package.json \
  --node-env node-env.nix \
  --output node-packages.nix \
  --composition node-composition.nix