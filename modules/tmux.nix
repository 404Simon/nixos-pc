{ config, pkgs, ... }:

let
  scriptsDir = "${config.home.homeDirectory}/nixos-pc/resources/shell/scripts";
in
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    escapeTime = 0;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];

    extraConfig = ''
      # Allow passthrough for image previews in neovim
      set -gq allow-passthrough on
      set -g visual-activity off

      # ============================================================================
      # Key Bindings
      # ============================================================================

      # Split windows
      unbind %
      bind u split-window -h -c "#{pane_current_path}"

      unbind '"'
      bind i split-window -v -c "#{pane_current_path}"

      # Reload config
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Resize panes
      bind j resize-pane -D 5
      bind k resize-pane -U 5
      bind l resize-pane -R 5
      bind h resize-pane -L 5

      # Toggle zoom
      bind -r m resize-pane -Z

      # Popup bindings
      bind -r g popup -d '#{pane_current_path}' -E -w 90% -h 90% lazygit
      bind -r t popup -d '#{pane_current_path}' -E -w 90% -h 90% ${config.home.homeDirectory}/dev/tuidict/target/release/tuidict
      bind -r r popup -d '#{pane_current_path}' -E -w 90% -h 90% ${config.home.homeDirectory}/dev/rmpc/target/release/rmpc

      # Copy mode bindings
      bind y copy-mode
      unbind -T copy-mode-vi MouseDragEnd1Pane
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # Window numbering
      setw -g pane-base-index 1
      set -g renumber-windows on
      bind C-l send-keys 'C-l'

      # Tmux sessionizer
      bind-key f run-shell "tmux neww ${scriptsDir}/tmux-sessionizer.sh"

      # ============================================================================
      # Theme Configuration (Dracula)
      # ============================================================================

      # Status line refresh interval
      set -g status-interval 1

      # Status line position
      set -g status-position bottom

      # Colors
      set -g status-bg "#282a36"  # Dracula background
      set -g status-fg "#f8f8f2"  # Dracula foreground

      # Left status section
      set -g status-left-length 40
      set -g status-left-style "fg=#50fa7b,bg=#282a36,bold" # Green
      set -g status-left "#[fg=#ff79c6,bg=#282a36,bold] #S #[fg=#f8f8f2,bg=#282a36,nobold]"

      # Window list
      setw -g window-status-current-style "fg=#bd93f9,bg=#44475a,bold" # Purple
      setw -g window-status-current-format " #I:#W#F "
      setw -g window-status-style "fg=#f8f8f2,bg=#282a36"
      setw -g window-status-format " #I:#W#F "
      setw -g window-status-separator ""

      # Right status section
      set -g status-right-length 150
      set -g status-right-style "fg=#f8f8f2,bg=#282a36"
      set -g status-right ""
      set -ga status-right "#(${scriptsDir}/tmux-notification-status.sh) "
      set -ga status-right "#[fg=#f1fa8c,bg=#282a36] %a %d.%m. #[fg=#bd93f9,bg=#282a36] %H:%M "

      # Message and Command line
      set -g message-style "fg=#bd93f9,bg=#44475a,bold"
      set -g display-panes-active-colour "#50fa7b"
      set -g display-panes-colour "#44475a"

      # Pane border colors
      set -g pane-border-style "fg=#44475a"
      set -g pane-active-border-style "fg=#bd93f9"
    '';
  };
}
