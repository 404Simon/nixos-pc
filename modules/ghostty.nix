{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "TokyoNight";
      background-opacity = 0.90;
      background-blur-radius = 20;
      gtk-titlebar = false;
      font-family = "JetBrains Mono Nerd Font Mono";
      confirm-close-surface = false;
      command = "tmux attach || tmux";
    };
  };
}
