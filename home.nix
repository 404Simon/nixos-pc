{ config, pkgs, ... }:

{

  imports = [
    ./modules/opencode.nix
    ./modules/git.nix
  ];

  home.username = "simon";
  home.homeDirectory = "/home/simon";
  programs.git.enable = true;
  home.stateVersion = "26.05";
  programs.zsh = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-pc#pc";
    };
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = false;
      expireDuplicatesFirst = false;
    };
  };

  home.packages = with pkgs; [
    neovim
    ripgrep
  ];

}
