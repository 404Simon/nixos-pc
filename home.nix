{ config, pkgs, ... }:

{
  imports = [
    ./modules/opencode.nix
    ./modules/git.nix
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/neovim.nix
    ./modules/tmux.nix
    # ./modules/ghostty.nix
    ./modules/foot.nix
    # ./modules/ironbar.nix
    ./modules/rumdl.nix
    ./modules/mpd.nix
    ./modules/rmpc.nix
    ./modules/mpv.nix
    ./modules/qutebrowser.nix
    ./modules/xdg.nix
    ./modules/simple-notifier.nix
    ./modules/zathura.nix
    ./modules/sioyek.nix
    ./modules/webapps.nix
  ];

  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
    options = [ "ctrl:nocaps" ];
  };

  xdg.configFile."kxkbrc".text = ''
    [Layout]
    LayoutList=de
    Options=ctrl:nocaps
    Use=true
    VariantList=nodeadkeys
  '';

  home.username = "simon";
  home.homeDirectory = "/home/simon";

  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
