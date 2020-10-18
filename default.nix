{ pkgs ? import <nixpkgs> { } }:
let
  pkgsWithLib = pkgs.extend (import ./lib/overlay.nix);
  newPkgs = import ./pkgs { pkgs = pkgsWithLib; };
  patchedPkgs = import ./patches { pkgs = pkgsWithLib // newPkgs; };
  myPkgs = newPkgs // patchedPkgs;
in
{
  lib = import ./lib pkgs.lib;
  modules = import ./modules;
  overlays = {
    lib = import ./lib/overlay.nix;
    pkgs = import ./pkgs/overlay.nix;
    patches = import ./patches/overlay.nix;
  };
} // myPkgs
