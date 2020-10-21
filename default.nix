{ pkgs ? import <nixpkgs> { } }:
let
  newPkgs = import ./pkgs { inherit pkgs; };
  patchedPkgs = import ./patches { pkgs = pkgs // newPkgs; };
  aasgPkgs = newPkgs // patchedPkgs;
in
{
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules;
  overlays = {
    pkgs = import ./pkgs/overlay.nix;
    patches = import ./patches/overlay.nix;
  };
} // aasgPkgs
