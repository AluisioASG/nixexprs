{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "esbuild";
  version = "0.7.14";

  src = fetchFromGitHub {
    owner = "evanw";
    repo = pname;
    rev = "v${version}";
    sha256 = "1y5hqymv2r8r29f8vh8kgncj3wlkg4fzi0zlc7mgyss872ajkc7i";
  };

  # For NixOS 20.03.
  modSha256 = "1p80k4s18br3idiy422bpa8hm53kjjdhd55v6yx908wqk4hpa5yh";
  # For NixOS 20.09 and up.
  vendorSha256 = "0325z7b58awzdzfgnzib2v36xah7rdnihamcd2spna1f1slingbn";

  subPackages = [ "./cmd/esbuild" ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    go test ./internal/...

    runHook postCheck
  '';

  meta = with lib; {
    description = "An extremely fast JavaScript bundler and minifier";
    homepage = "https://github.com/evanw/esbuild";
    license = licenses.mit;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.all;
  };
}
