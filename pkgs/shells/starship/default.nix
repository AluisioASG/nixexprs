{ fetchFromGitHub, lib, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "starship";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "starship";
    repo = "starship";
    rev = "v${version}";
    sha256 = "0cj3r8c583xzraggwl1xb36790czha4dja6c3yvn5f19whmmf2g9";
  };

  cargoSha256 = "1cg0vqsgnm35n0fdbc9vgpa44gs2g3f6vcqm80sbz28xc7rs19gr";

  meta = with lib; {
    description = "Minimal, fast, customizable cross-shell prompt";
    homepage = "https://starship.rs";
    license = licenses.isc;
    platforms = platforms.all;
    maintainers = [ maintainers.AluisioASG ];
  };
}
