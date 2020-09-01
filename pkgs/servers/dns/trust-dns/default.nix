{ lib, callPackage, defaultCrateOverrides }:

(callPackage ./Cargo.nix { }).workspaceMembers.trust-dns.build.override {
  features = [ "dns-over-rustls" ];
  crateOverrides = defaultCrateOverrides // {
    trust-dns = attrs: {
      meta = with lib; {
        description = "Rust-based DNS client, server, and resolver";
        homepage = "https://github.com/bluejekyll/trust-dns";
        license = licenses.mit;
        maintainers = with maintainers; [ AluisioASG ];
        platforms = platforms.all;
      };
    };
  };
}
