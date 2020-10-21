{ pkgs }:
/*
 * Merge of the Nixpkgs and aasg libs.
 */
let
  lib = pkgs.lib;
  aasgLib = import ./. { inherit pkgs; };
in
aasgLib.updateNewRecursive lib aasgLib
