{ config, lib, pkgs, ... }:
with lib;
let
  format = pkgs.formats.toml { };
  cfg = config.services.trust-dns;
  configFile = format.generate "named.toml" cfg.settings;
in
{
  options = {
    services.trust-dns = {
      enable = mkEnableOption "Trust-DNS authoritative server";

      package = mkOption {
        type = types.package;
        default = pkgs.trust-dns;
        defaultText = "pkgs.trust-dns";
        description = "Trust-DNS package to use.";
      };

      user = mkOption {
        type = types.str;
        default = "trust-dns";
        description = "User under which the Trust-DNS server runs";
      };

      group = mkOption {
        type = types.str;
        default = "trust-dns";
        description = "Group under which the Trust-DNS server runs";
      };

      settings = mkOption {
        type = format.type;
        default = { };
        description = "Additional Trust-DNS settings.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.trust-dns = {
      description = "Trust-DNS authoritative server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/named -c ${configFile}";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-abnormal";
        StartLimitInterval = 14400;
        StartLimitBurst = 10;
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        TimeoutStopSec = "5s";
      };
    };
  };
}
