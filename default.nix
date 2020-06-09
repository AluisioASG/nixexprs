{ pkgs ? import <nixpkgs> { } }:

{
  modules = import ./modules;
  overlays = {
    pkgs = import ./pkgs/overlay.nix;
  };
} // (import ./pkgs { inherit pkgs; })
