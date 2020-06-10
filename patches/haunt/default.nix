{ pkgs }:

{
  haunt = pkgs.haunt.overrideAttrs (oldAttrs: rec {
    patches = [ ./restore-raw.patch ];
  });
}
