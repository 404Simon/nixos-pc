{ config, pkgs, ... }:

let
  # nvidia + wayland has a known egl context creation issue with qt6
  sioyek-wrapped = pkgs.symlinkJoin {
    name = "sioyek-wrapped";
    paths = [ pkgs.sioyek ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/sioyek \
        --run 'if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -d /sys/module/nvidia ]; then export QT_QPA_PLATFORM=xcb; fi'
    '';
  };

  copy-text-script = pkgs.writeShellScript "sioyek-copy-text" ''
    ${pkgs.poppler-utils}/bin/pdftotext -f $(($1 + 1)) -l $(($1 + 1)) "$2" - | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  copy-page-script = pkgs.writeShellScript "sioyek-copy-page" ''${pkgs.poppler-utils}/bin/pdftoppm -png -f $(($1 + 1)) -l $(($1 + 1)) "$2" | ${pkgs.wl-clipboard}/bin/wl-copy'';
in
{
  programs.sioyek = {
    enable = true;
    package = sioyek-wrapped;
    bindings = {
      "toggle_presentation_mode" = "p";
      "_copy_text" = "y";
      "_copy_page" = "Y";
    };

    config = {
      "new_command" = "_copy_text ${copy-text-script} %{page_number} %{file_path}";
      "new_command " = "_copy_page ${copy-page-script} %{page_number} %{file_path}";
    };
  };
}
