{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "esbuild";
  version = "0.7.8";

  src = fetchFromGitHub {
    owner = "evanw";
    repo = pname;
    rev = "v${version}";
    sha256 = "1xxdwn20wlv5d2khv56jihbdcy68s6k258d4j2jqq3nrir72sf46";
  };

  # For NixOS 20.03.
  modSha256 = "1p80k4s18br3idiy422bpa8hm53kjjdhd55v6yx908wqk4hpa5yh";
  # For NixOS 20.09 and up.
  vendorSha256 = "0325z7b58awzdzfgnzib2v36xah7rdnihamcd2spna1f1slingbn";

  subPackages = [ "./cmd/esbuild" ];

  checkPhase = ''
    go test ./internal/...
  '';

  meta = with lib; {
    description = "An extremely fast JavaScript bundler and minifier";
    homepage = "https://github.com/evanw/esbuild";
    license = licenses.mit;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.all;
  };
}
