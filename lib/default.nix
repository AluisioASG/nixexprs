super:
let
  callLibs = file: import file { lib = super // self; };
  self = rec {
    lists = callLibs ./lists.nix;
    inherit (lists) indexOf isSubsetOf;
  };
in
self
