final: prev:

{

  bird-lg = final.callPackage ./servers/monitoring/bird-lg { };

  dma = final.callPackage ./tools/networking/dma { };

  drep = final.callPackage ./tools/text/drep {
    inherit (final.darwin.apple_sdk.frameworks) CoreServices;
  };

  dyndnsc = final.callPackage ./tools/networking/dyndnsc { };

  esbuild = final.callPackage ./development/tools/esbuild { };

  guile-commonmark = final.callPackage ./development/guile-modules/guile-commonmark { };

  guile-json = final.callPackage ./development/guile-modules/guile-json { };

  haunt = final.callPackage ./applications/misc/haunt { };

  iwgtk = final.callPackage ./applications/networking/iwgtk { };

  linuxPackagesFor = kernel:
    (prev.linuxPackagesFor kernel).extend (import ./os-specific/linux/kernel-packages.nix);

  python3 = prev.python3.override { packageOverrides = import ./development/python-modules; self = final.python3; };

  shellharden = final.callPackage ./development/tools/shellharden { };

  trust-dns = final.callPackage ./servers/dns/trust-dns { };

}
