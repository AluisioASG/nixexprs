{ ... }:

# Based on https://gist.github.com/lheckemann/402e61e8e53f136f239ecd8c17ab1deb
{ file # Path to the environment definition file
, withPkgs # Function returning the packages to install
, name ? pkgs.lib.removeSuffix ".nix" (baseNameOf file) # Name of the environment
, drvName ? "${name}-environment" # Name of the generated derivaqtion
, profile ? "/nix/var/nix/profiles/${name}" # Path to the profile
, pkgs ? import <nixpkgs> { } # Nixpkgs
}: with pkgs;

buildEnv {
  name = drvName;
  extraOutputsToInstall = [ "out" "bin" "lib" ];
  paths = (withPkgs pkgs) ++ [
    nix
    glibcLocales

    (writeScriptBin "update-profile" ''
      #!${stdenv.shell}
      nix-env -p ${profile} --set -f ${file} --argstr drvName "${name}-environment-$(date -I)"
    '')
    # Manifest to make sure imperative nix-env doesn't work (otherwise it will overwrite the profile, removing all packages other than the newly-installed one).
    (writeTextFile {
      name = "break-nix-env-manifest";
      destination = "/manifest.nix";
      text = ''
        throw "Your user environment is a buildEnv which is incompatible with nix-env's built-in env builder. Edit your home expression and run update-profile instead!"
      '';
    })
    # To allow easily seeing which nixpkgs version the profile was built from, place the version string in ~/.nix-profile/nixpkgs-version
    (writeTextFile {
      name = "nixpkgs-version";
      destination = "/nixpkgs-version";
      text = pkgs.lib.version;
    })
  ];
}
