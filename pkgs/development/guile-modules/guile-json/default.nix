{ stdenv, lib, pkgconfig, guile }:

stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "4.3.2";

  src = builtins.fetchTarball {
    url = "https://download.savannah.nongnu.org/releases/guile-json/guile-json-${version}.tar.gz";
    sha256 = "1ciqx3zhyl703lv7s2whi860lq9455z56c5w26zvx6fdlblgz84p";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ guile ];

  configureFlags = [
    "--datarootdir=$(out)/share"
    "--libdir=$(out)/share"
  ];
  makeFlags = [
    "GUILE_EFFECTIVE_VERSION="
    "objdir=$(out)/share/guile/site/site-ccache"
  ];

  doCheck = true;

  meta = with lib; {
    description = "JSON module for Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
