{ stdenv, fetchFromGitHub, fetchpatch, graphviz, python3, traceroute, whois }:
let
  runtimeDeps = [
    (python3.withPackages (ps: with ps; [
      flask
      dnspython
      gunicorn
      pydot
      memcached
    ]))
    graphviz
    whois
    traceroute
  ];
in
stdenv.mkDerivation rec {
  pname = "bird-lg-burble";
  version = "2020-05-20-unstable";

  src = fetchFromGitHub {
    owner = "sesa-me";
    repo = "bird-lg";
    rev = "f3699a3b61f2d9f77cb17fb163bcf3c3ad722835"; # refs/head/burble-clean
    sha256 = "0gisi6mbfclw36kms3qy3b0wzcwdkd50p2a6xdwggln4fi5y6bh1";
  };

  patches = [
    (fetchpatch {
      name = "fix-bgpmap-generation.patch";
      url = "https://github.com/sesa-me/bird-lg/commit/db8fb829d51889fab61bfb5ffac89199442d3117.patch";
      sha256 = "1vwr7ck5v7w4fr78kbc4wxyj3licsw7h0772xkmmxsb8vp9vcihg";
    })
  ];

  WRAPPER_PATH = stdenv.lib.makeBinPath runtimeDeps;
  WRAPPER_PYTHONPATH = placeholder "out";

  installPhase = ''
    function wrapWSGI {
      set -e
      substitute ${./run-wsgi.sh} "$2" \
        --subst-var shell \
        --subst-var WRAPPER_PATH \
        --subst-var WRAPPER_PYTHONPATH \
        --subst-var-by SCRIPT "$1"
      chmod +x "$2"
    }

    runHook preInstall
    mkdir -p $out $out/bin
    cp -r * $out
    touch $out/__init__.py
    wrapWSGI lg:app $out/bin/bird-lg-webservice
    wrapWSGI lgproxy:app $out/bin/bird-lg-proxy
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Looking glass for the BIRD Internet Routing Daemon";
    homepage = "https://github.com/sesa-me/bird-lg";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
