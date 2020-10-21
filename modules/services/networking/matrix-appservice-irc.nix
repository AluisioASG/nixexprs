{ config, lib, pkgs, ... }:
with import ../../../lib/extension.nix { inherit pkgs; };
let
  format = pkgs.formats.yaml { };
  cfg = config.services.matrix-appservice-irc;
  pkg = cfg.package;

  configSchema = pkgs.runCommand "matrix-appservice-irc-schema.json" { } ''
    ${pkgs.remarshal}/bin/remarshal -if yaml -of json <${pkg}/lib/node_modules/matrix-appservice-irc/config.schema.yml >$out
  '';
  configFile = pkgs.runCommandLocal "matrix-appservice-irc.json"
    {
      nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.jsonschema ])) ];
      config = builtins.toJSON cfg.settings;
      passAsFile = [ "config" ];
    }
    ''
      python -m jsonschema ${configSchema} -i $configPath
      cp $configPath $out
    '';

  registrationFile =
    let
      hs = cfg.settings.homeserver;
      hostname =
        if (builtins.match "^[[:xdigit:]:]{2,39}$" hs.bindHostname) != null
        then "[${hs.bindHostname}]" # IPv6 literal
        else hs.bindHostname;
      serviceUrl = "http://${hostname}:${toString hs.bindPort}";
    in
    pkgs.runCommandLocal "matrix-appservice-registration-irc.yaml" { } ''
      ${pkg}/bin/matrix-appservice-irc --config ${configFile} --file $out \
        --generate-registration \
        --url "${serviceUrl}"
    '';
in
{
  options = {
    services.matrix-appservice-irc = {
      enable = mkEnableOption "Matrix bridge to IRC";

      package = mkOption {
        type = types.package;
        default = pkgs.matrix-appservice-irc;
        defaultText = "pkgs.matrix-appservice-irc";
        description = "matrix-appservice-irc package to use.";
      };

      settings = mkOption {
        type = format.type;
        default = { };
        description = "Additional service settings.";
      };

      botPasswordFiles = mkOption {
        type = types.attrsOf types.path;
        description = ''
          Attrset mapping IRC servers to files containing the password
          of the bridge bot on that server.
        '';
        default = { };
        example = ''
          { "chat.freenode.net" = "/etc/matrix-appservice-irc/freenode.password"; }
        '';
      };

      registrationFile = mkOption {
        type = types.path;
        description = "Path to the registration file (generated automatically).";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [
        {
          assertion = isSubsetOf (builtins.attrNames cfg.settings.ircService.servers) (builtins.attrNames cfg.botPasswordFiles);
          message = "botPasswordFiles references servers not present in the settings";
        }
      ];

    services.matrix-appservice-irc.registrationFile = registrationFile;

    systemd.services.matrix-appservice-irc = {
      description = "Matrix bridge to IRC";
      wantedBy = [ "multi-user.target" ];
      preStart =
        let
          botPasswords = mapAttrsToList
            (server: passwordFile: ''
              ${pkgs.jq}/bin/jq --null-input \
                --arg server "${server}" --rawfile password "${passwordFile}" \
                '{ircService: {servers: {($server): {botConfig: {password: $password | rtrimstr("\n")}}}}}'
            '')
            cfg.botPasswordFiles;
        in
        ''
          set -euo pipefail
          umask 077
          # Replace bot passwords in config file.
          {
            ${concatStringsSep "\n" botPasswords}
          } | ${pkgs.jq}/bin/jq --slurp 'reduce .[] as $item ({}; . * $item)' \
            ${configFile} - >$RUNTIME_DIRECTORY/config.json
        '';
      serviceConfig = rec {
        Type = "simple";
        ExecStart = "${pkg}/bin/matrix-appservice-irc --config \${RUNTIME_DIRECTORY}/config.json --file ${registrationFile}";
        DynamicUser = true;
        ProtectHome = true;
        PrivateDevices = true;
        ConfigurationDirectory = "matrix-appservice-irc";
        ConfigurationDirectoryMode = "0700";
        RuntimeDirectory = "matrix-appservice-irc";
        RuntimeDirectoryMode = "0700";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        CapabilityBoundingSet = [ ];
        AmbientCapabilities = CapabilityBoundingSet;
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;
        PrivateMounts = true;
        SystemCallFilter = "~@aio @clock @cpu-emulation @debug @keyring @memlock @module @mount @obsolete @raw-io @setuid @swap";
        SystemCallArchitectures = "native";
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
      };
    };
  };
}
