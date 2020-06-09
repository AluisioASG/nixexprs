{ pkgs }:
let
  self = (import ./overlay.nix) (self // pkgs) pkgs;
in
self
