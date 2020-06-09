self: super:

{

  dma = super.callPackage ./tools/networking/dma { inherit (self) flex openssl yacc; };

  dyndnsc = super.callPackage ./tools/networking/dyndnsc { inherit (self) python3Packages; };

  guile-commonmark = super.callPackage ./development/guile-modules/guile-commonmark {
    inherit (self) pkgconfig guile;
  };

  haunt = super.callPackage ./applications/misc/haunt {
    inherit (self) pkgconfig guile guile-commonmark guile-reader;
  };

  linuxPackagesFor = kernel:
    (super.linuxPackagesFor kernel).extend (import ./os-specific/linux/kernel-packages.nix);

  python3 = super.python3.override { packageOverrides = import ./development/python-modules; };

  starship = super.callPackage ./shells/starship { inherit (self) rustPlatform; };

}
