{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: let
  work-browser = pkgs.callPackage ./programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    any-nix-shell # fish support for nix shell
    #arandr               # simple GUI for xrandr
    asciinema # record the terminal
    audacious # simple music player
    bitwarden-cli # command-line client for the password manager
    bottom # alternative to htop & ytop
    cachix # nix caching
    calibre # e-book reader
    cobang # qr-code scanner
    dconf2nix # dconf (gnome) files to nix converter
    dmenu # application launcher
    docker-compose # docker manager
    dive # explore docker layers
    discord
    drawio # diagram design
    duf # disk usage/free utility
    exa # a better `ls`
    fd # "find" for files
    gimp # gnu image manipulation program
    glow # terminal markdown viewer
    gnomecast # chromecast local files
    hyperfine # command-line benchmarking tool
    insomnia # rest client with graphql support
    jitsi-meet-electron # open source video calls and chat
    jmtpfs # mount mtp devices
    killall # kill processes by name
    libreoffice # office suite
    libnotify # notify-send command
    mr
    betterlockscreen # fast lockscreen based on i3lock
    ncdu # disk space info (a better du)
    neofetch # command-line system information
    nfs-utils
    ngrok # secure tunneling to localhost
    nix-index # locate packages containing certain nixpkgs
    nyancat # the famous rainbow cat!
    #md-toc               # generate ToC in markdown files
    pavucontrol # pulseaudio volume control
    paprefs # pulseaudio preferences
    pasystray # pulseaudio systray
    #pgcli               # modern postgres client (FIXME: broken on nixpkgs)
    playerctl # music player controller
    prettyping # a nicer ping
    protonvpn-gui # official proton vpn client
    pulsemixer # pulseaudio mixer
    ranger # terminal file explorer
    ripgrep # fast grep
    rnix-lsp # nix lsp server
    simple-scan # scanner gui
    simplescreenrecorder # screen recorder gui
    skypeforlinux # messaging client
    slack # messaging client
    tdesktop # telegram messaging client
    #tex2nix              # texlive expressions for documents
    tldr # summary of a man page
    tree # display files in a tree view
    vlc # media player
    vscodium
    xsel # clipboard support (also for neovim)
    yad # yet another dialog - fork of zenity

    # work stuff
    work-browser

    # fixes the `ar` error required by cabal
    binutils-unwrapped
  ];

  gitPkgs = with pkgs.gitAndTools; [
    diff-so-fancy # git diff with colors
    git-crypt # git files encryption
    hub # github command-line client
    tig # diff and commit view
  ];

  gnomePkgs = with pkgs.gnome3; [
    eog # image viewer
    evince # pdf reader
    nautilus # file manager
  ];

  haskellPkgs = with pkgs.haskellPackages; [
    brittany # code formatter
    cabal2nix # convert cabal projects to nix
    cabal-install # package manager
    ghc # compiler
    haskell-language-server # haskell IDE (ships with ghcide)
    hoogle # documentation
    nix-tree # visualize nix dependencies
  ];

  polybarPkgs = with pkgs; [
    font-awesome # awesome fonts
    material-design-icons # fonts with glyphs
    xfce.orage # lightweight calendar
  ];

  scripts = pkgs.callPackage ./scripts/default.nix {inherit config pkgs;};

  securityPkgs = with pkgs; [
    yubikey-manager # yubikey manager cli
    yubioath-desktop # yubikey OTP manager (gui)
    keepass
    gnupg # Security ##
    ledger-live-desktop # Ledger Nano X Support for NixOS
  ];

  cardanoGuildPkgs = with pkgs; [
    bc # required for gLiveView
  ];

  xmonadPkgs = with pkgs; [
    networkmanager_dmenu # networkmanager on dmenu
    networkmanagerapplet # networkmanager applet
    nitrogen # wallpaper manager
    xcape # keymaps modifier
    xorg.xkbcomp # keymaps modifier
    xorg.xmodmap # keymaps modifier
    xorg.xrandr # display manager (X Resize and Rotate protocol)
  ];
in {
  programs.home-manager.enable = true;

  imports = (import ./modules) ++ (import ./programs) ++ (import ./services) ++ [(import ./themes)];

  xdg.enable = true;

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "bismuth";
    homeDirectory = "/home/bismuth";
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    stateVersion = "22.11";
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    packages = defaultPkgs ++ cardanoGuildPkgs ++ gitPkgs ++ gnomePkgs ++ haskellPkgs ++ polybarPkgs ++ scripts ++ xmonadPkgs ++ securityPkgs;
    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
    };
  };

  systemd.user.startServices = "sd-switch";

  news.display = "silent";
  # Let Home Manager install and manage itself.

  nixpkgs.overlays = [
    (import ./overlays/beauty-line)
    (import ./overlays/coc-nvim)
  ];

  nixpkgs.config = {
    # Allow unfree, which is required for some drivers.
    allowUnfree = true;
  };

  programs = {
    bat.enable = true;

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = ["--height 20%"]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };

    gpg.enable = true;

    htop = {
      enable = true;
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };

    jq.enable = true;

    obs-studio = {
      enable = true;
      plugins = [];
    };

    ssh.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [];
    };

    # programs with custom modules
    megasync.enable = true;
    spotify.enable = true;
  };

  services = {
    flameshot.enable = true;
  };
}
