{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  callPackageWithMerged = attrName: f: extraArgs:
    let
      mergedSubset = pkgs.${attrName} // self.${attrName};
      subsetArgs = builtins.listToAttrs [{ name = attrName; value = mergedSubset; }];
    in
    callPackage f (subsetArgs // extraArgs);
  self = rec {

    dma = callPackage ./tools/networking/dma { };

    drep = callPackage ./tools/text/drep { };

    dyndnsc = callPackageWithMerged "python3Packages" ./tools/networking/dyndnsc { };

    esbuild = callPackage ./development/tools/esbuild { };

    guile-commonmark = callPackage ./development/guile-modules/guile-commonmark { };

    guile-json = callPackage ./development/guile-modules/guile-json { };

    haunt = callPackage ./applications/misc/haunt { };

    iwgtk = callPackage ./applications/networking/iwgtk { };

    linuxPackages = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux);
    linuxPackages_latest = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_latest);
    linuxPackagesFor = kernel:
      let
        ksuper = pkgs.linuxPackagesFor kernel;
        kself = import ./os-specific/linux/kernel-packages.nix (ksuper // kself) ksuper;
      in
      pkgs.lib.makeExtensible (_: kself);

    python3Packages =
      let
        pysuper = pkgs.python3Packages;
        pyself = import ./development/python-modules (pysuper // pyself) pysuper;
      in
      pkgs.recurseIntoAttrs pyself;

    shellharden = callPackage ./development/tools/shellharden { };

    trust-dns = callPackage ./servers/dns/trust-dns { };

  };
in
self
