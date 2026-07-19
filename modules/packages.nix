{ pkgs, pkgs-unstable, ... }:

{
  home.packages =
    (with pkgs; [
      (vivaldi.override { proprietaryCodecs = true; })
      ungoogled-chromium
      kdePackages.dolphin
      kdePackages.kdenlive
      imagemagick
      rsync
      restic
      localsend
      pdftk
      pdfchain
      diceware
      wakeonlan
      exiftool
      zip
      unzip
      unrar-free
      ripgrep
      fd
      fwupd
      yt-dlp
      poppler-utils
      ffmpeg-full
      feh
      gum
      jq
      tldr
      fastfetch
      subfinder
      fluffychat
      ncdu
      mise
      lazysql
      lazydocker
      nixfmt
      nil # Nix LSP server
      tree-sitter
      nodejs
      go
      gcc
      gnumake
      uv
      rustup # includes cargo
      php
      phpPackages.composer
      bun
      pnpm
      yazi
      keepassxc
      zapzap
      signal-desktop
      obs-studio
      radicle-node

      # Uni
      eduvpn-client
      networkmanager-openvpn
      texlive.combined.scheme-full
      pandoc
      typst
      plantuml
      apostrophe
      obsidian
      onlyoffice-desktopeditors
      libreoffice
      anki
      zotero
      xournalpp
      xlsx2csv

      calcure
      newsboat
      socat
      sweethome3d.application

      napari

      # Gaming
      moonlight-qt

      # Photography
      kdePackages.gwenview
      rawtherapee
      inkscape

      # python with global packages
      (pkgs.python3.withPackages (
        ps: with ps; [
          pylatexenc
        ]
      ))
    ])
    ++ (with pkgs-unstable; [
      pangolin-cli
      librepods
      mixxx
      codex
      vscode
      tabiew
      tex-fmt
      just
    ]);
}
