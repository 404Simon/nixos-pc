{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    luajit
  ];

  home.activation.createNvimLink = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -L "${config.home.homeDirectory}/.config/nvim" ]; then
      rm -rf "${config.home.homeDirectory}/.config/nvim"
      ln -sfn "${config.home.homeDirectory}/nixos-pc/resources/nvim" "${config.home.homeDirectory}/.config/nvim"
    fi
  '';
}
