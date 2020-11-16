{ stdenv, lib, pkgs, makeWrapper, nodejs, nodePackages, ... }:
let
  inherit (lib) attrValues findSingle;

  ourNodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  nodePackage = findSingle
    (drv: drv ? packageName && drv.packageName == "matrix-appservice-irc")
    (throw "no 'matrix-appservice-irc' package found in nodePackages")
    (throw "multiple 'matrix-appservice-irc' packages found in nodePackages")
    (attrValues ourNodePackages);
in
nodePackage.override {
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodePackages.node-gyp-build ];

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/matrix-appservice-irc" \
      --add-flags "$out/lib/node_modules/matrix-appservice-irc/app.js"
  '';

  meta = with lib; {
    description = "Node.js IRC bridge for Matrix";
    homepage = "https://github.com/matrix-org/matrix-appservice-irc";
    license = licenses.asl20;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.all;
  };
}
