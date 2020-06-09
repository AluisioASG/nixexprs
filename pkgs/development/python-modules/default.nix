pyself: pysuper:

{
  daemonocle = pysuper.callPackage ./daemonocle { inherit (pyself) click psutil; };
}
