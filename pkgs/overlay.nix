final: prev:

{

  dma = prev.callPackage ./tools/networking/dma { };

  drep = prev.callPackage ./tools/text/drep { };

  dyndnsc = prev.callPackage ./tools/networking/dyndnsc { };

  esbuild = prev.callPackage ./development/tools/esbuild { };

  guile-commonmark = prev.callPackage ./development/guile-modules/guile-commonmark { };

  guile-json = prev.callPackage ./development/guile-modules/guile-json { };

  haunt = prev.callPackage ./applications/misc/haunt { };

  iwgtk = prev.callPackage ./applications/networking/iwgtk { };

  linuxPackagesFor = kernel:
    (prev.linuxPackagesFor kernel).extend (import ./os-specific/linux/kernel-packages.nix);

  python3 = prev.python3.override { packageOverrides = import ./development/python-modules; };

  shellharden = prev.callPackage ./development/tools/shellharden { };

  trust-dns = prev.callPackage ./servers/dns/trust-dns { };

}
