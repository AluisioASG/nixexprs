{ pkgs ? import <nixpkgs> { } }:
let
  withNewCallPackage = set: set // { callPackage = pkgs.lib.callPackageWith set; };
  myPkgs = import ./pkgs { inherit pkgs; };
  myPatchedPkgs = import ./patches { pkgs = withNewCallPackage (pkgs // myPkgs); };
in
{
  modules = import ./modules;
  overlays = {
    pkgs = import ./pkgs/overlay.nix;
    patches = import ./patches/overlay.nix;
  };
} // myPatchedPkgs
