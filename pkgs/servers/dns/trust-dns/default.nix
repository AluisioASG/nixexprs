{ lib
, callPackage
, defaultCrateOverrides
, features ? [ ]
}:
let
  attrs = {
    patches = [ ./udp-reuseaddr.patch ];

    meta = with lib; {
      description = "Rust-based DNS client, server, and resolver";
      homepage = "https://github.com/bluejekyll/trust-dns";
      license = licenses.mit;
      maintainers = with maintainers; [ AluisioASG ];
      platforms = platforms.all;
    };
  };

  crates = callPackage ./Cargo.nix {
    rootFeatures = features;
    defaultCrateOverrides = defaultCrateOverrides // {
      trust-dns = oldAttrs: attrs;
    };
  };

in
crates.rootCrate.build
