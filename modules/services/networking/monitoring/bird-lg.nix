{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mkDefault mkEnableOption mkIf mkOption types;
  settingsFormat = pkgs.formats.json { };

  cfg = config.services.bird-lg;
in
{

  options = {
    services.bird-lg.server = {
      enable = mkEnableOption "BIRD looking glass server";

      appSettings = mkOption {
        description = "Configuration for bird-lg's server.";
        type = settingsFormat.type;
        default = { };
      };

      gunicornSettings = mkOption {
        description = "Configuration for the Gunicorn instance running bird-lg's server.";
        type = settingsFormat.type;
        default = { };
      };

      extraConfigFiles = mkOption {
        description = "Extra JSON files containing configuration, for example secrets.";
        type = types.listOf types.path;
        default = [ ];
      };
    };

    services.bird-lg.client = {
      enable = mkEnableOption "BIRD looking glass client proxy";

      appSettings = mkOption {
        description = "Configuration for bird-lg's client proxy.";
        type = settingsFormat.type;
        default = { };
      };

      gunicornSettings = mkOption {
        description = "Configuration for the Gunicorn instance running bird-lg's client proxy.";
        type = settingsFormat.type;
        default = { };
      };

      extraConfigFiles = mkOption {
        description = "Extra JSON files containing configuration, for example secrets.";
        type = types.listOf types.path;
        default = [ ];
      };
    };
  };

  config = {

    ################
    # Server setup #
    ################

    services.bird-lg.server.appSettings = {
      DEBUG = mkDefault true;
      PROXY = mkDefault { };
      PROXY_TIMEOUT = mkDefault {
        bird = 10;
        traceroute = 60;
      };
      UNIFIED_DAEMON = mkDefault true;
    };

    systemd.services.bird-lg-server = mkIf cfg.server.enable {
      description = "BIRD looking glass web server";
      requires = [ "network-online.target" ];
      after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BIRD_LG_CONFIG_FILES = concatStringsSep ":" ([
          (settingsFormat.generate "bird-lg-gunicorn.json" cfg.server.gunicornSettings)
          (settingsFormat.generate "bird-lg.json" cfg.server.appSettings)
        ] ++ cfg.server.extraConfigFiles);
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bird-lg}/bin/bird-lg-webservice --config=${pkgs.bird-lg}/config-loader.py";
        Restart = "on-failure";

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

    services.bird-lg.client.appSettings = {
      DEBUG = mkDefault false;
      LOG_LEVEL = "WARNING";
      BIRD_SOCKET = "/run/bird.ctl";
      BIRD6_SOCKET = "/run/bird6.ctl";
    };

    systemd.services.bird-lg-client = mkIf cfg.client.enable {
      description = "BIRD looking glass client proxy";
      requires = [ "network-online.target" ];
      after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BIRD_LG_CONFIG_FILES = concatStringsSep ":" ([
          (settingsFormat.generate "bird-lgproxy-gunicorn.json" cfg.client.gunicornSettings)
          (settingsFormat.generate "bird-lgproxy.json" cfg.client.appSettings)
        ] ++ cfg.client.extraConfigFiles);
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bird-lg}/bin/bird-lg-proxy --config=${pkgs.bird-lg}/config-loader.py";
        Restart = "on-failure";

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
