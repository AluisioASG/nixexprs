{ pkgs ? import <nixpkgs> { } }:

{
  modules = import ./modules;
  overlays = {
    pkgs = import ./pkgs/overlay.nix;
    patches = import ./patches/overlay.nix;
  };
} // (import ./pkgs { inherit pkgs; })
