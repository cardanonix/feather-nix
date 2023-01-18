{ config, lib, pkgs, stdenv, inputs, ... }:

let
  username = "bismuth";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  # workaround to open a URL in a new tab in the specific firefox profile
  work-browser = pkgs.callPackage ./programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    aalib                # make ASCI text 
    any-nix-shell        # fish support for nix shell
    arandr               # simple GUI for xrandr
    asciinema            # record the terminal
    audacious            # simple music player
    binutils-unwrapped   # fixes the `ar` error required by cabal
    bc                   # required for Cardano Guild gLiveView
    bottom               # alternative to htop & ytop
    cachix               # nix caching
    calibre              # e-book reader
    dconf2nix            # dconf (gnome) files to nix converter
    dmenu                # application launcher
    docker-compose       # docker manager
    dive                 # explore docker layers
    drawio               # diagram design
    duf                  # disk usage/free utility
    exa                  # a better `ls`
    fd                   # "find" for files
    glow                 # terminal markdown viewer
    gnomecast            # chromecast local files
    hyperfine            # command-line benchmarking tool
    insomnia             # rest client with graphql support
    jmtpfs               # mount mtp devices
    killall              # kill processes by name
    libreoffice          # office suite
    libnotify            # notify-send command4
    betterlockscreen     # fast lockscreen based on i3lock
    niv                  # painless dependencies for Nix projects
    ncdu                 # disk space info (a better du)
    nfs-utils            # utilities for NFS
    ngrok                # secure tunneling to localhost
    nix-index            # locate packages containing certain nixpkgs
    md-toc               # generate ToC in markdown files
    openjdk
    obsidian             # note taking/mind mapping
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pgcli                # modern postgres client
    playerctl            # music player controller
    prettyping           # a nicer ping
    protonvpn-gui        # official proton vpn client
    pulsemixer           # pulseaudio mixer
    ranger               # terminal file explorer
    ripgrep              # fast grep
    rnix-lsp             # nix lsp server
    simple-scan          # scanner gui
    simplescreenrecorder # screen recorder gui
    tex2nix              # texlive expressions for documents
    tldr                 # summary of a man page
    tree                 # display files in a tree view
    ungoogled-chromium   # chrome without the Goog 
    xsel                 # clipboard support (also for neovim)
    yad                  # yet another dialog - fork of zenity
    xssproxy             # suspends screensaver when watching a video (forward org.freedesktop.ScreenSaver calls to Xss)
    xautolock            # autolock stuff
    jupyter              # pyton jupyter notebooks
    lorri                # needed for direnv
    ihp-new              # Haskell web framework (the Django of Haskell)
    python3Packages.ipython
    srm
    pinentry

    # Work Stuff
    work-browser

    #  Messaging and Social Networks
    element-desktop      # matrix client
    discord              # discord app (breaks often)
    tdesktop             # telegram messaging client
    slack                # messaging client
    tootle               # mastodon client of choice

    #  Ricing
    cmatrix              # dorky terminal matrix effect
    nyancat              # the famous rainbow cat!  
    ponysay              # for sweet Audrey
    cowsay               # cowsay fortune teller with random images
    pipes                # pipes vis in terminal

    #  Security
    rage                 # encryption tool for secrets management
    keepassxc            # Security ##
    gnupg                # Security ##
    ledger-live-desktop  # Ledger Nano X Support for NixOS
    bitwarden-cli        # command-line client for the password manager
  ];

  cpuHungryPkgs = with pkgs; [
    vlc                  # media player
    darktable            # raw photo manipulation and grading
    mpv                  # media player
    #kodi                 # media player  
    gimp                 # gnu image manipulation program
    blender              # 3D computer graphics software tool set
    krita                # image editor (supposedly better than gimp)
    mkvtoolnix           # tools for encoding MKV files, etc
    filebot              # batch renaming
    kdenlive             # super nice video editor
    mlt                  # kdenlive uses the MLT framework to process all video operations
    mediainfo            # additional package for kdenlive
    inkscape
    fontforge
  ];

  homePkgs = with pkgs; [
    hue-cli              # lights for my residence
    mr                   # mass github actions
  ];

  gnomePkgs = with pkgs.gnome; [
    eog            # image viewer
    evince         # pdf reader
    gucharmap      # gnome character map (for font creation) 
    #nautilus # file manager

    # file manager overlay
    pkgs.nautilus-gtk3
    #pkgs.nautilus-bin
    #pkgs.nautilus-patched
  ];

  haskellPkgs = with pkgs.haskellPackages; [
    #brittany               # code formatter (broken because of Multistate 0.8.0.4)
    cabal2nix               # convert cabal projects to nix
    cabal-install           # package manager
    ghc                     # compiler
    stack
    haskell-language-server # haskell IDE (ships with ghcide)
    hoogle                  # documentation
    nix-tree                # visualize nix dependencies
    ihaskell
    ihaskell-blaze 
  ];

  cardanoNodePkgs = with inputs.cardano-node.packages.x86_64-linux; [
    #TODO: how do I build the configuration bundle instead of just the executable inside of my config?
    #https://github.com/input-output-hk/cardano-node/blob/master/doc/getting-started/building-the-node-using-nix.md
    cardano-node
    cardano-cli
    cardano-submit-api 
    cardano-tracer 
    bech32 
    locli  
    db-analyser
    /*plutus-example
      error (ignored): error: end of string reached
      error: the path '~/.gitconfig' can not be resolved in pure mode 
    */
  ];

  rustPkgs = with pkgs; [
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
  ];

in

{
  programs.home-manager.enable = true;

  imports = builtins.concatMap import [
    ./modules
    ./programs
    ./scripts
    ./services
    ./themes
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory;
    stateVersion = "22.11";

    packages = defaultPkgs ++ gnomePkgs ++ haskellPkgs ++ cpuHungryPkgs ++ cardanoNodePkgs ++ rustPkgs ++ homePkgs; 

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
      CARDANO_NODE_SOCKET_PATH = "/Cardano/mainnet/db/node.socket";
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
