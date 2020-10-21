{ lib }:
let
  callLibs = file: import file { inherit lib; aasgLib = self; };
  self = rec {
    attrsets = callLibs ./attrsets.nix;
    inherit (attrsets) capitalizeAttrNames updateNew updateNewRecursive;

    declareEnvironment = lib.makeOverridable (callLibs ./declarative-env.nix);

    extended = import ./extension.nix { inherit lib; };

    lists = callLibs ./lists.nix;
    inherit (lists) indexOf isSubsetOf;

    strings = callLibs ./strings.nix;
    inherit (strings) capitalize;
  };
in
self
