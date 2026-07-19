{ pkgs, ... }:

{
  home.packages = [ pkgs.rumdl ];

  xdg.configFile."rumdl/rumdl.toml".text = ''
    [global]
    disable = ["MD013", "MD025"]
  '';
}
