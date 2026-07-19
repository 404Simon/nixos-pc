{ config, pkgs, ... }:

{
  programs.qutebrowser = {
    enable = true;

    greasemonkey = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/master/youtube_sponsorblock.js";
        sha256 = "sha256-2sNlWL0KOAOMe2pllyKVBT4gAICokyDOuHPkVfUrYN4=";
      })
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/iamfugui/youtube-adb/main/index.user.js";
        sha256 = "sha256-2/nwJY+3vC1fs5bKTnPWpoG3QKFOpf9WIq0cSetrBOg=";
      })
      (pkgs.fetchurl {
        url = "https://greasyfork.org/scripts/540190/code/youtube-shorts-blocker.user.js";
        sha256 = "sha256-2maNEhbH5eFzqyQ9ts2jKQMfMOvP8DfzAfY/flILxqs=";
      })
    ]
    ++ builtins.map (
      file:
      pkgs.runCommand file { } ''
        cp ${../resources/qutebrowser/greasemonkey + "/${file}"} $out
      ''
    ) (builtins.attrNames (builtins.readDir ../resources/qutebrowser/greasemonkey));

    settings = {
      auto_save.session = true;
      scrolling.smooth = false;
      colors.webpage.darkmode.enabled = true;
      downloads.location.directory = "~/Downloads";
      content.pdfjs = true;

      # Ad blocking
      content.blocking.enabled = true;
      content.blocking.method = "both";
      content.blocking.adblock.lists = [
        "https://easylist.to/easylist/easylist.txt"
        "https://easylist.to/easylist/easyprivacy.txt"
        "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
      ];

      # Privacy
      content.cookies.accept = "no-3rdparty";
      content.headers.do_not_track = true;
      content.headers.referer = "same-domain";
      content.webgl = false;
      content.canvas_reading = false;
      content.webrtc_ip_handling_policy = "default-public-interface-only";
      content.notifications.enabled = false;
      content.autoplay = false;
      url.auto_search = "naive";
      completion.web_history.max_items = 1000;
      colors.webpage.darkmode.algorithm = "lightness-cielab";
      colors.webpage.darkmode.policy.images = "never";

      url.default_page = "about:blank";
      url.start_pages = [ "about:blank" ];
    };

    searchEngines = {
      DEFAULT = "https://www.startpage.com/sp/search?query={}";
      g = "https://www.google.com/search?q={}";
      gh = "https://github.com/search?q={}";
      nw = "https://wiki.nixos.org/w/index.php?search={}";
      np = "https://search.nixos.org/packages?query={}";
      no = "https://search.nixos.org/options?query={}";
      wiki = "https://en.wikipedia.org/wiki/Special:Search?search={}";
      dhl = "https://www.dhl.de/de/privatkunden/pakete-empfangen/verfolgen.html?piececode={}";
      hermes = "https://www.myhermes.de/empfangen/sendungsverfolgung/sendungsinformation#{}";
      cargo = "https://crates.io/search?q={}";
      yt = "https://www.youtube.com/results?search_query={}";
      sc = "https://soundcloud.com/search?q={}";
      gs = "https://scholar.google.com/scholar?q={}";
      pm = "https://pubmed.ncbi.nlm.nih.gov/?term={}";
      klein = "https://www.kleinanzeigen.de/s-{}/k0";
      geiz = "https://geizhals.de/?fs={}&hloc=de";
    };

    quickmarks = {
      yt = "https://www.youtube.com";
      my = "https://www.mydealz.de";
      gh = "https://github.com";
      campo = "https://www.campo.fau.de";
      gem = "https://gemini.google.com/app";
      lm = "https://notebooklm.google.com/";
      sc = "https://soundcloud.com/discover";
      klein = "https://www.kleinanzeigen.de";
      rr = "https://app.researchrabbit.ai/search";
      geiz = "https://geizhals.de";
    };

    keyBindings.normal = {
      # dark mode
      "<Ctrl-d>" = "config-cycle colors.webpage.darkmode.enabled";
      # video playback speed
      "d" =
        "jseval -q var v = document.querySelector('video'); if(v) { v.playbackRate = Math.min(v.playbackRate + 0.1, 8); window.qute_speed_display?.remove(); var d = document.createElement('div'); d.id = 'qute_speed_display'; d.textContent = 'Speed: ' + v.playbackRate.toFixed(1) + 'x'; d.style = 'position:fixed;top:20px;right:20px;background:rgba(0,0,0,0.8);color:white;padding:10px 20px;border-radius:5px;z-index:2147483647;font-size:20px;font-family:sans-serif;pointer-events:none'; var target = document.fullscreenElement || document.body; target.appendChild(d); setTimeout(() => d.remove(), 1000); }";
      "s" =
        "jseval -q var v = document.querySelector('video'); if(v) { v.playbackRate = Math.max(v.playbackRate - 0.1, 0.25); window.qute_speed_display?.remove(); var d = document.createElement('div'); d.id = 'qute_speed_display'; d.textContent = 'Speed: ' + v.playbackRate.toFixed(1) + 'x'; d.style = 'position:fixed;top:20px;right:20px;background:rgba(0,0,0,0.8);color:white;padding:10px 20px;border-radius:5px;z-index:2147483647;font-size:20px;font-family:sans-serif;pointer-events:none'; var target = document.fullscreenElement || document.body; target.appendChild(d); setTimeout(() => d.remove(), 1000); }";
      "V" =
        "config-cycle -p content.cookies.accept all no-3rdparty ;; config-cycle -p content.headers.referer always same-domain ;; config-cycle -p content.canvas_reading true false ;; config-cycle -p colors.webpage.darkmode.enabled false true";
      "ysc" =
        "jseval -q (function(){ const url = document.querySelector(\".playbackSoundBadge__titleLink \").href; navigator.clipboard.writeText(url); })();";
    };
  };
}
