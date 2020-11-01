{ pkgs ? import <nixpkgs> { }
, flake-utils-lib ? import (fetchTarball {
    url = "https://github.com/numtide/flake-utils/archive/588973065fce51f4763287f0fda87a174d78bf48.tar.gz";
    sha256 = "17h8rcp246y3444l9fp92jz1h5gp4gvgpnnd8rmhq686mdbha02r";
  })
}:
let
  inherit (builtins) deepSeq concatStringsSep listToAttrs mapAttrs;
  inherit (pkgs) recurseIntoAttrs;
  inherit (pkgs.lib.attrsets) filterAttrs getAttrFromPath isDerivation mapAttrsToList nameValuePair;
  inherit (pkgs.lib.strings) splitString;
  inherit (pkgs.lib.trivial) flip pipe;

  newPackages = selectDerivations (import ./pkgs { inherit pkgs; });

  patchedPackages = selectDerivations (import ./patches { pkgs = pkgs.extend (import ./pkgs/overlay.nix); });

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

  flattenAttrsFromPaths = paths: set:
    listToAttrs
      (map
        (path: nameValuePair (concatStringsSep "__" path) (getAttrFromPath path set))
        paths);

  packagePaths = (flip pipe) [
    flake-utils-lib.flattenTree
    (mapAttrsToList (name: _: splitString "/" name))
  ];

in
{
  lib = deepSeq (import ./lib/tests.nix { lib = pkgs.lib; }) { };

  newPackagesDirect = newPackages;

  newPackagesOverlay = pipe [ ./pkgs/overlay.nix ] [
    (map import)
    pkgs.appendOverlays
    (flattenAttrsFromPaths (packagePaths newPackages))
    recurseIntoAttrs
  ];

  patchedPackagesDirect = patchedPackages;

  patchedPackagesOverlay = pipe [ ./pkgs/overlay.nix ./patches/overlay.nix ] [
    (map import)
    pkgs.appendOverlays
    (flattenAttrsFromPaths (packagePaths patchedPackages))
    recurseIntoAttrs
  ];
}
