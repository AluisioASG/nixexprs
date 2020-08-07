{ pkgs ? import <nixpkgs> { } }:
let
  myPkgs = import ./pkgs { inherit pkgs; };
  myPatchedPkgs = import ./patches { pkgs = pkgs // myPkgs; };
in
{
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules;
  overlays = {
    pkgs = import ./pkgs/overlay.nix;
    patches = import ./patches/overlay.nix;
  };
} // myPkgs // myPatchedPkgs
