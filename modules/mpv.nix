{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    config = {
      gpu-context = "wayland";
      loop-file = "inf";
    };
  };

  xdg.configFile."mpv/scripts/mousepos.lua".source = ../resources/mpv/scripts/mousepos.lua;
  xdg.configFile."mpv/scripts/speed_stepper.lua".source = ../resources/mpv/scripts/speed_stepper.lua;
  xdg.configFile."mpv/scripts/vim_time_jump.lua".source = ../resources/mpv/scripts/vim_time_jump.lua;
}
