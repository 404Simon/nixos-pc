{ config, pkgs, ... }:

let
  correctPathsScript = pkgs.writeShellScript "correct_paths.sh" ''
    #!/usr/bin/env bash
    cd ${config.home.homeDirectory}/Music/mpd/playlists
    for file in *.m3u; do sed -i '/^$/d; /^#/d; s|^[^.]|../../&|' "$file"; done
  '';
in
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/mpd/playlists";

    extraConfig = ''
      # Database
      db_file "${config.home.homeDirectory}/Music/mpd/database"

      # Logs and state
      log_file "${config.home.homeDirectory}/.mpd/log"
      state_file "${config.home.homeDirectory}/.mpd/state"
      sticker_file "${config.home.homeDirectory}/.mpd/sticker.sql"

      # Connection
      bind_to_address "${config.home.homeDirectory}/.mpd/socket"

      # Audio Output
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }

      # Input
      input {
        plugin "curl"
      }

      # Volume normalization
      replaygain "track"
      replaygain_preamp "0"
      replaygain_missing_preamp "-6"
      replaygain_limit "yes"
    '';
  };

  home.file."Music/mpd/playlists/correct_paths.sh" = {
    source = correctPathsScript;
    executable = true;
  };

  systemd.user.services.mpd-correct-paths = {
    Unit = {
      Description = "Correct MPD playlist paths";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${correctPathsScript}";
    };
  };

  systemd.user.timers.mpd-correct-paths = {
    Unit = {
      Description = "Run MPD playlist path correction every 5 minutes";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  home.activation.mpdDirectories = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/.mpd
    mkdir -p ${config.home.homeDirectory}/Music/mpd/playlists
    mkdir -p ${config.home.homeDirectory}/Music/mpd/lyrics
  '';
}
