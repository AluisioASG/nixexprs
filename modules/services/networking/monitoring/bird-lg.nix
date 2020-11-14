{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;

  jsonFormat = pkgs.formats.json { };
  pyJSONFormat =
    {
      type = jsonFormat.type;
      generate = name: value: pkgs.runCommandNoCC
        name
        {
          passAsFile = [ "script" "value" ];
          value = builtins.toJSON value;
          script = ''
            import json
            import sys
            value = json.load(sys.stdin)
            print("globals().update({!r})".format(value), file=sys.stdout)
          '';
        }
        ''
          ${pkgs.python3}/bin/python $scriptPath <$valuePath >$out
        '';
    };

  cfg = config.services.bird-lg;
  serverGunicornConfigFile = pyJSONFormat.generate "bird-lg-gunicorn.py" cfg.server.gunicornSettings;
  clientGunicornConfigFile = pyJSONFormat.generate "bird-lgproxy-gunicorn.py" cfg.client.gunicornSettings;
in
{

  options = {
    services.bird-lg.server = {
      enable = mkEnableOption "BIRD looking glass server";

      appSettings = mkOption {
        description = "Configuration for bird-lg's server.";
        type = jsonFormat.type;
        default = { };
      };

      gunicornSettings = mkOption {
        description = "Configuration for the Gunicorn instance running bird-lg's server.";
        type = pyJSONFormat.type;
        default = { };
      };
    };

    services.bird-lg.client = {
      enable = mkEnableOption "BIRD looking glass client proxy";

      appSettings = mkOption {
        description = "Configuration for bird-lg's client proxy.";
        type = jsonFormat.type;
        default = { };
      };

      gunicornSettings = mkOption {
        description = "Configuration for the Gunicorn instance running bird-lg's client proxy.";
        type = pyJSONFormat.type;
        default = { };
      };
    };
  };

  config = {

    ################
    # Server setup #
    ################

    environment.etc."bird-lg/lg.json" = mkIf cfg.server.enable {
      source = jsonFormat.generate "bird-lg.json" cfg.server.appSettings;
    };

    systemd.services.bird-lg-server = mkIf cfg.server.enable {
      description = "BIRD looking glass web server";
      requires = [ "network-online.target" ];
      after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bird-lg}/bin/bird-lg-webservice --config=${serverGunicornConfigFile}";
        Restart = "on-failure";

        WorkingDirectory = "/etc/bird-lg";
        ConfigurationDirectory = "/etc/bird-lg";

        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
        PrivateTmp = true;
        DevicePolicy = "closed";
        MemoryDenyWriteExecute = true;
      };
    };

    ######################
    # Client proxy setup #
    ######################

    environment.etc."bird-lg/lgproxy.json" = mkIf cfg.client.enable {
      source = jsonFormat.generate "bird-lgproxy.json" cfg.client.appSettings;
    };

    systemd.services.bird-lg-client = mkIf cfg.client.enable {
      description = "BIRD looking glass client proxy";
      requires = [ "network-online.target" ];
      after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bird-lg}/bin/bird-lg-proxy --config=${clientGunicornConfigFile}";
        Restart = "on-failure";

        WorkingDirectory = "/etc/bird-lg";
        ConfigurationDirectory = "/etc/bird-lg";

        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
        PrivateTmp = true;
        DevicePolicy = "closed";
      };
    };

  };

}
