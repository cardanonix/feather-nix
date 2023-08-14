{
  config,
  lib,
  pkgs,
  stdenv,
  inputs,
  ...
}: let
  username = "bismuth";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";
  # workaround to open a URL in a new tab in the specific firefox profile
  work-browser = pkgs.callPackage ./programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    aalib # make ASCI text
    any-nix-shell # fish support for nix shell
    niv
    lorri # needed for direnv
    arandr # simple GUI for xrandr
    asciinema # record the terminal
    audacious # simple music player
    bottom # alternative to htop & ytop
    cachix # nix caching
    calibre # e-book reader
    dconf2nix # dconf (gnome) files to nix converter
    dmenu # application launcher
    docker-compose # docker manager
    dive # explore docker layers
    duf # disk usage/free utility
    exa # a better `ls`
    fd # "find" for files
    glow # terminal markdown viewer
    # gnomecast            # chromecast local files
    hyperfine # command-line benchmarking tool
    insomnia # rest client with graphql support
    jmtpfs # mount mtp devices
    killall # kill processes by name
    libnotify # notify-send command4
    ncdu # disk space info (a better du)
    nfs-utils # utilities for NFS
    ngrok # secure tunneling to localhost
    nix-index # locate packages containing certain nixpkgs
    md-toc # generate ToC in markdown files
    adoptopenjdk-bin
    pavucontrol # pulseaudio volume control
    paprefs # pulseaudio preferences
    pasystray # pulseaudio systray
    pgcli # modern postgres client
    playerctl # music player controller
    prettyping # a nicer ping
    protonvpn-gui # official proton vpn client
    pulsemixer # pulseaudio mixer
    ranger # terminal file explorer
    ripgrep # fast grep
    rnix-lsp # nix lsp server
    simple-scan # scanner gui
    simplescreenrecorder # screen recorder gui
    #tex2nix              # texlive expressions for documents
    tldr # summary of a man page
    tree # display files in a tree view
    ungoogled-chromium # chrome without the Goog
    xsel # clipboard support (also for neovim)
    yad # yet another dialog - fork of zenity
    xssproxy # suspends screensaver when watching a video (forward org.freedesktop.ScreenSaver calls to Xss)
    xautolock # autolock stuff
    srm # a command-line compatible rm(1) which overwrites file contents before unlinking.
    pinentry # a small collection of dialog programs that allow GnuPG to read passphrases and PIN numbers in a secure manner
    spago
    feh

    libsForQt5.gwenview # my favorite image viewer (for now)

    # Work Stuff
    work-browser

    #  Messaging and Social Networks
    element-desktop # matrix client
    discord # discord app (breaks often)
    tdesktop # telegram messaging client
    slack # slack messaging client

    #  Ricing
    cmatrix # dorky terminal matrix effect
    nyancat # the famous rainbow cat!
    ponysay # for sweet Audrey
    cowsay # cowsay fortune teller with random images

    #  Security
    rage # encryption tool for secrets management
    keepassxc # Security ##
    gnupg # Security ##
    ledger-live-desktop # Ledger Nano X Support for NixOS
    bitwarden-cli # command-line client for the password manager
  ];

  gnomePkgs = with pkgs.gnome; [
    eog # image viewer
    evince # pdf reader
    gucharmap # gnome character map (for font creation)

    # file manager overlay
    #nautilus # file manager
    pkgs.nautilus-gtk3
    pkgs.fontforge-gtk
    #pkgs.nautilus-bin
    #pkgs.nautilus-patched
  ];
in {
  programs.home-manager.enable = true;

  imports = builtins.concatMap import [
    ./modules
    ./programs
    ./scripts
    ./services
    ./themes
    # ./secrets/bismuth_home.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory;
    stateVersion = "22.11";

    packages = defaultPkgs ++ gnomePkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
    };

    pointerCursor = {
      name = "phinger-cursors";
      package = pkgs.phinger-cursors;
      size = 25;
      gtk.enable = true;
    };
  };

  # restart services on change
  systemd.user.startServices = "sd-switch";

  xsession.numlock.enable = true;

  # notifications about home-manager news
  news.display = "silent";
}
