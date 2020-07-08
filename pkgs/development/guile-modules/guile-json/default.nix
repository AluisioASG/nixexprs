{ stdenv, lib, pkgconfig, guile }:

stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "4.3.0";

  src = builtins.fetchTarball {
    url = "https://download.savannah.nongnu.org/releases/guile-json/guile-json-${version}.tar.gz";
    sha256 = "1daqswls05z7nlhvcwi32agh6h94jk7smn6liw4vrigwiqiz0cg2";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ guile ];

  makeFlags = [
    "moddir=$(out)/share/guile/site"
    "objdir=$(out)/share/guile/site/site-ccache"
  ];

  meta = with lib; {
    description = "JSON module for Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
