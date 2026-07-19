{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    luajit
  ];

  home.sessionPath = [ "${config.home.homeDirectory}/.config/nvim/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  home.activation.createNvimLink = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -L "${config.home.homeDirectory}/.config/nvim" ]; then
      rm -rf "${config.home.homeDirectory}/.config/nvim"
      ln -sfn "${config.home.homeDirectory}/nixos-pc/resources/nvim" "${config.home.homeDirectory}/.config/nvim"
    fi
  '';
}
