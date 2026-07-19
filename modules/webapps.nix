{ lib, pkgs, ... }:

let
  mkWebApp =
    {
      name,
      url,
      comment ? null,
      icon ? null,
      categories ? [ "Network" ],
    }:
    pkgs.makeDesktopItem {
      inherit name categories;
      desktopName = name;
      exec = "${pkgs.ungoogled-chromium}/bin/chromium --app=\"${url}\"";
      comment = if comment != null then comment else "Web App: ${name}";
      icon = if icon != null then icon else "web-browser";
    };
in
{
  home.packages = [
    (mkWebApp {
      name = "Google Calendar";
      url = "https://calendar.google.com";
    })
    (mkWebApp {
      name = "Google Maps";
      url = "https://maps.google.com";
    })
    (mkWebApp {
      name = "Immich";
      url = "https://immich.404simon.de/photos";
    })
    (mkWebApp {
      name = "Paperless";
      url = "https://paperless.404simon.de";
    })
    (mkWebApp {
      name = "Campo";
      url = "https://www.campo.fau.de";
    })
    (mkWebApp {
      name = "Overleaf";
      url = "https://www.overleaf.com/project/6a58d6e46c66edeec9d89320";
    })
    (mkWebApp {
      name = "Geogebra";
      url = "https://www.geogebra.org/classic?lang=en";
    })
  ];
}
