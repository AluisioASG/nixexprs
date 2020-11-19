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

      logToSyslog = mkOption {
        description = "Whether to log to journald via syslog instead of writing to stderr.";
        type = types.bool;
        default = true;
      };

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

      logToSyslog = mkOption {
        description = "Whether to log to journald via syslog instead of writing to stderr.";
        type = types.bool;
        default = true;
      };

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
      LOG_LEVEL = mkDefault "WARNING";
      PROXY = mkDefault { };
      PROXY_TIMEOUT = mkDefault {
        bird = 10;
        traceroute = 60;
      };
      UNIFIED_DAEMON = mkDefault true;
    };

    services.bird-lg.server.gunicornSettings = mkIf cfg.server.logToSyslog {
      errorlog = mkDefault "/dev/null";
      syslog = mkDefault true;
      syslog_addr = mkDefault "unix:///dev/log";
    };

    systemd.services.bird-lg-server = mkIf cfg.server.enable {
      description = "BIRD looking glass web server";
      requires = [ "network-online.target" ];
      after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BIRD_LG_CONFIG = ./bird-lg-config.py;
        BIRD_LG_CONFIG_FILES = concatStringsSep ":" ([
          (settingsFormat.generate "bird-lg-gunicorn.json" cfg.server.gunicornSettings)
          (settingsFormat.generate "bird-lg.json" cfg.server.appSettings)
        ] ++ cfg.server.extraConfigFiles);
        BIRD_LG_SYSLOG = toString cfg.server.logToSyslog;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bird-lg}/bin/bird-lg-webservice --config=\${BIRD_LG_CONFIG}";
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
      LOG_LEVEL = mkDefault "WARNING";
      BIRD_SOCKET = mkDefault "/run/bird.ctl";
      BIRD6_SOCKET = mkDefault "/run/bird6.ctl";
    };

    services.bird-lg.client.gunicornSettings = mkIf cfg.client.logToSyslog {
      errorlog = mkDefault "/dev/null";
      syslog = mkDefault true;
      syslog_addr = mkDefault "unix:///dev/log#dgram";
    };

    systemd.services.bird-lg-client = mkIf cfg.client.enable {
      description = "BIRD looking glass client proxy";
      requires = [ "network-online.target" ];
      after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BIRD_LG_CONFIG = ./bird-lg-config.py;
        BIRD_LG_CONFIG_FILES = concatStringsSep ":" ([
          (settingsFormat.generate "bird-lgproxy-gunicorn.json" cfg.client.gunicornSettings)
          (settingsFormat.generate "bird-lgproxy.json" cfg.client.appSettings)
        ] ++ cfg.client.extraConfigFiles);
        BIRD_LG_SYSLOG = toString cfg.client.logToSyslog;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bird-lg}/bin/bird-lg-proxy --config=\${BIRD_LG_CONFIG}";
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
