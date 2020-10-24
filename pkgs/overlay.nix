self: super:

{

  dma = super.callPackage ./tools/networking/dma { };

  drep = super.callPackage ./tools/text/drep { };

  dyndnsc = super.callPackage ./tools/networking/dyndnsc { };

  esbuild = super.callPackage ./development/tools/esbuild { };

  guile-commonmark = super.callPackage ./development/guile-modules/guile-commonmark { };

  guile-json = super.callPackage ./development/guile-modules/guile-json { };

  haunt = super.callPackage ./applications/misc/haunt { };

  iwgtk = super.callPackage ./applications/networking/iwgtk { };

  linuxPackagesFor = kernel:
    (super.linuxPackagesFor kernel).extend (import ./os-specific/linux/kernel-packages.nix);

  python3 = super.python3.override { packageOverrides = import ./development/python-modules; };

  shellharden = super.callPackage ./development/tools/shellharden { };

  trust-dns = super.callPackage ./servers/dns/trust-dns { };

}
