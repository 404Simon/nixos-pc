{ config, pkgs, ... }:

let
  scriptsDir = "${config.home.homeDirectory}/nixos-pc/resources/shell/scripts";
in
{
  programs.zsh = {
    enable = true;

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 1000000;
      save = 1000000;
      share = true;
      extended = true;
      expireDuplicatesFirst = true;
    };

    completionInit = ''
      autoload -Uz compinit
      compinit

      zstyle ':completion:*' matcher-list \
        'm:{a-z}={A-Za-z} r:|=*' \
        'm:{a-z}={A-Za-z} l:|=* r:|=*'

      zstyle ':completion:*' menu select=1
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Ignore patterns for vim/nvim
      zstyle ':completion:*:*:vim:*:*files' ignored-patterns '*.pdf' '*.class'
      zstyle ':completion:*:*:nvim:*:*files' ignored-patterns '*.pdf' '*.class'
    '';

    initContent = ''
      setopt inc_append_history

      # -------------------------------------------------------------
      # Custom Tab Completion for .. -> ../
      # -------------------------------------------------------------
      insert-slash-if-dotdot() {
        if [[ ''${LBUFFER: -2} == '..' ]]; then
          LBUFFER+='/'
        else
          zle expand-or-complete
        fi
      }

      zle -N insert-slash-if-dotdot
      bindkey '^I' insert-slash-if-dotdot

      # -------------------------------------------------------------
      # Custom Functions
      # -------------------------------------------------------------

      # Weather function
      function weather() {
          location="''${*:-Erlangen}"
          location="''${location// /+}"
          curl -s "wttr.in/$location" | sed '1d;$d;$d'
      }

      # Pomodoro functions
      icon=~/Pictures/pumpkin.png
      MPV_IPC_SOCKET="/tmp/mpv-socket"

      mpv_send_command() {
        local command_json="$1"
        if command -v socat >/dev/null; then
          if pgrep mpv >/dev/null; then
            if [[ -S "$MPV_IPC_SOCKET" ]]; then
              echo "$command_json" | socat - "$MPV_IPC_SOCKET" 2>/dev/null
            fi
          fi
        else
          echo "Error: 'socat' not found. Cannot control mpv via IPC." >&2
        fi
      }

      notify() {
        notify-send -i "$icon" "$1" "$2"
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga
      }

      timer() { (sleep "$1" && notify-send "Timer" "Time's up! ($1)" -u critical) &>/dev/null & disown; }

      work() {
        mpv_send_command '{ "command": ["set_property", "pause", false] }'
        timer ''${1:-25}m && \
        mpv_send_command '{ "command": ["set_property", "pause", true] }'
        notify "Work Timer is up! Take a Break 😊" "Santa 🎅🏼"
      }

      chill() {
        timer ''${1:-7}m && \
        notify "Break is over! Get back to work 😬" "Santa 🎅🏼"
      }

      # Open function with completion
      op() {
          xdg-open "$@" >/dev/null 2>&1 &
          disown
      }
      compdef '_files -g "*.(pdf|PDF|epub)"' op

      slug() {
        local s="$(wl-paste)"
        s="$(echo "$s" | sed 's/[^a-zA-Z0-9_-]/_/g;s/__*/_/g;s/^_//;s/_$//')"
        echo -n "$s" | wl-copy
        echo "$s"
      }

      function anki() {
          if ! pgrep anki > /dev/null; then
              anki &
          fi
          for i in $(seq 1 30); do
              ss -tln 2>/dev/null | grep -q :3141 && break
              echo "waiting for Anki MCP server..."
              sleep 1
          done
          opencode --agent anki "$@"
      }

      # Laravel completions
      if command -v laravel >/dev/null 2>&1; then
        eval "$(laravel completion)"
      fi

      # Typst completions
      eval "$(typst completions zsh)"

      # Vesskel completions
      eval "$(vesskel completions zsh)"
    '';

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-pc#pc";
      t = "tmux a || tmux";
      y = "yazi";
      g = "lazygit";
      fzf = "fzf --tmux 80%,80%";
      ls = "eza --color=always --icons=always";
      pp = "pnpm";
      mm = "/home/simon/dev/musicmatch/.venv/bin/musicmatch";
      artisan = "php artisan";
      pint = "./vendor/bin/pint";
      stan = "./vendor/bin/phpstan";
      pest = "./vendor/bin/pest";
      rector = "./vendor/bin/rector";
      sail = "./vendor/bin/sail";
      db = "lazysql \"file:database/database.sqlite?loc=auto\"";

      dev = "eval \"$(${scriptsDir}/projectnavigator.sh)\"";
      v = "eval \"$(${scriptsDir}/vorlesungsnavigator.sh)\"";
      m = "eval \"$(${scriptsDir}/musicnavigator.sh)\"";
      o = "cd \"$OBSIDIAN_VAULT\" && nvim";

      blog = "~/dev/quartz/automation.sh";
      lyrics = "${scriptsDir}/lyric_search.py";
      plz = "${scriptsDir}/plz.sh";
      song = "${scriptsDir}/song.sh";
      jo = "cd /home/simon/dev/VesSkel";

      c = "calcure";
      n = "newsboat";
      r = "rmpc";

      suspend = "systemctl suspend";
      open = "xdg-open";
      todo = "vim ~/Vorlesungen/TODO.md";
      b = "bg && disown";
      shutdown = "systemctl poweroff";
      reboot = "systemctl reboot";
      gaming = "ssh xmg.server \"wakeonlan 88:d7:f6:7a:5d:eb\"";
      luft = "${scriptsDir}/airpods.sh";
    };
  };

  # ============================================================================
  # Environment Variables
  # ============================================================================
  home.sessionVariables = {
    EDITOR = "nvim";
    OBSIDIAN_VAULT = "/home/simon/obsidian-vault/";

    FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git";
    FZF_CTRL_T_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git";
    FZF_ALT_C_COMMAND = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    FZF_DEFAULT_OPTS = "--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED";

    JAVA_HOME = "$HOME/.jdks/selected_java/java";
    GRAAL_HOME = "$HOME/.jdks/selected_java/java";
    GRAALVM_HOME = "$HOME/.jdks/selected_java/java";

  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "$HOME/.composer/vendor/bin"
    "$HOME/.config/composer/vendor/bin"
    "$HOME/.jdks/selected_java/java/bin"
    scriptsDir
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";

    changeDirWidgetOptions = [ "--preview 'eza --tree --color=always {}'" ];
    fileWidgetOptions = [ "--preview 'bat --color=always {}'" ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "always";
    git = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "tokyonight_night";
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "matcha-dark-sea";
    };
  };

  # Copy custom theme
  xdg.configFile."bat/themes/tokyonight_night.tmTheme".source =
    ../resources/bat/tokyonight_night.tmTheme;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        truncate_to_repo = false;
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          "~/dev" = "δ";
          "dotfiles" = "⚙ ";
          "nixos-pc" = "";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };

      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };

      nodejs = {
        symbol = "";
        detect_files = [ "package.json" ];
        detect_extensions = [
          "mjs"
          "cjs"
          "ts"
          "mts"
          "cts"
        ];
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      php = {
        symbol = "🐘";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      python = {
        symbol = "🐍";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };

      time = {
        disabled = true;
        time_format = "%R";
        style = "bg:#1d2230";
        format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
      };

      direnv = {
        disabled = false;
        style = "bg:#212736";
        format = "[[ $symbol: $loaded/$allowed ](fg:#769ff0 bg:#212736)]($style)";
      };
    };
  };
}
