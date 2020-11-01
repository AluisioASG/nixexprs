{ pkgs ? import <nixpkgs> { }
, flake-utils-lib ? import (fetchTarball {
    url = "https://github.com/numtide/flake-utils/archive/588973065fce51f4763287f0fda87a174d78bf48.tar.gz";
    sha256 = "17h8rcp246y3444l9fp92jz1h5gp4gvgpnnd8rmhq686mdbha02r";
  })
}:
let
  inherit (pkgs.lib.attrsets) filterAttrs getAttrFromPath isDerivation listToAttrs mapAttrsToList nameValuePair recurseIntoAttrs;
  inherit (pkgs.lib.strings) concatStringsSep splitString;
  inherit (pkgs.lib.trivial) pipe;

  newPackages = pipe (import ./pkgs { inherit pkgs; }) [
    flake-utils-lib.flattenTree
    (filterAttrs (_: isDerivation))
    (mapAttrsToList (name: _: splitString "/" name))
  ];

  patchedPackages = pipe (import ./patches { inherit pkgs; }) [
    flake-utils-lib.flattenTree
    (filterAttrs (_: isDerivation))
    (mapAttrsToList (name: _: splitString "/" name))
  ];

  flattenAttrsFromPaths = paths: set:
    listToAttrs
      (map
        (path: nameValuePair (concatStringsSep "__" path) (getAttrFromPath path set))
        paths);
in
{
  lib = builtins.deepSeq (import ./lib/tests.nix { lib = pkgs.lib; }) { };

  newPackagesDirect = pipe { inherit pkgs; } [
    (import ./pkgs)
    (flattenAttrsFromPaths newPackages)
    recurseIntoAttrs
  ];

  newPackagesOverlay = pipe [ ./pkgs/overlay.nix ] [
    (map import)
    pkgs.appendOverlays
    (flattenAttrsFromPaths newPackages)
    recurseIntoAttrs
  ];

  patchedPackagesOverlay = pipe [ ./pkgs/overlay.nix ./patches/overlay.nix ] [
    (map import)
    pkgs.appendOverlays
    (flattenAttrsFromPaths patchedPackages)
    recurseIntoAttrs
  ];
}
