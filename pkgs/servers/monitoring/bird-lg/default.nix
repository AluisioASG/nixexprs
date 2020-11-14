{ stdenv, fetchFromGitHub, graphviz, python3, traceroute, whois }:
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

  postPatch = ''
    # Don't configure a log file; let systemd handle it.
    sed -i '/file_handler/d' lg.py lgproxy.py

    # Replace the builtin config file with one that reads JSON files
    # given through an environment variable.
    sed -i '/app\.config\.from_pyfile/c app.config.from_pyfile("config-loader.py")' lg.py lgproxy.py
  '';

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
    cp ${./config-loader.py} $out/config-loader.py
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
