super:
let
  callLibs = file: import file { lib = super // self; };
  self = rec {
    declareEnvironment = callLibs ./declarative-env.nix;

    lists = callLibs ./lists.nix;
    inherit (lists) indexOf isSubsetOf;
  };
in
self
