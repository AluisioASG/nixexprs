{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) recurseIntoAttrs;
  inherit (pkgs.lib) deepSeq filterAttrs isDerivation mapAttrs pipe;

  selectDerivations = set:
    let
      derivationTree = value:
        if isDerivation value
        then value
        else if value ? recurseForDerivations && value.recurseForDerivations == true
        then
          pipe value [
            (mapAttrs (name: derivationTree))
            (filterAttrs (name: value: value != null))
            recurseIntoAttrs
          ]
        else null;
    in
    derivationTree (recurseIntoAttrs set);

  self = import ./. { inherit pkgs; };
in
{
  lib = deepSeq (import ./lib/tests.nix { lib = pkgs.lib; }) { };

  newPackages = selectDerivations self.packageSets.pkgs;

  patchedPackages = selectDerivations self.packageSets.patches;
}
