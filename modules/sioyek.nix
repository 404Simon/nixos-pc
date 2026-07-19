{ config, pkgs, ... }:

let
  copy-text-script = pkgs.writeShellScript "sioyek-copy-text" ''
    ${pkgs.poppler-utils}/bin/pdftotext -f $(($1 + 1)) -l $(($1 + 1)) "$2" - | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  copy-page-script = pkgs.writeShellScript "sioyek-copy-page" ''${pkgs.poppler-utils}/bin/pdftoppm -png -f $(($1 + 1)) -l $(($1 + 1)) "$2" | ${pkgs.wl-clipboard}/bin/wl-copy'';
in
{
  programs.sioyek = {
    enable = true;
    bindings = {
      "toggle_presentation_mode" = "p";
      "_copy_text" = "y";
      "_copy_page" = "Y";
    };

    config = {
      "new_command" = "_copy_text ${copy-text-script} %{page_number} %{file_path}";
      # i hate this
      "new_command " = "_copy_page ${copy-page-script} %{page_number} %{file_path}";
    };
  };
}
