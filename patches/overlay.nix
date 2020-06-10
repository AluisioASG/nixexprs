self: super:
let
  patches = [ ./haunt ];
in
builtins.foldl' (set: path: set // (import path { pkgs = (super // set); })) { } patches
