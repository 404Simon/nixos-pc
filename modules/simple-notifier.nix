{ config, pkgs, ... }:

{
  systemd.user.services.simple-notifier = {
    Unit = {
      Description = "Simple notifier daemon - monitors sources and sends email notifications";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      WorkingDirectory = "/home/simon/dev/simple-notifier";
      ExecStart = "/home/simon/dev/simple-notifier/target/release/simple-notifier";
      Restart = "on-failure";
      RestartSec = "30s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
