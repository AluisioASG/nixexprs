{ pkgs }:
let
  lib = pkgs.lib;
  callLibs = file: import file { lib = lib; aasgLib = self; };
  self = rec {
    attrsets = callLibs ./attrsets.nix;
    inherit (attrsets) updateNew updateNewRecursive;

    declareEnvironment = lib.makeOverridable (callLibs ./declarative-env.nix);

    lists = callLibs ./lists.nix;
    inherit (lists) indexOf isSubsetOf;
  };
in
self
