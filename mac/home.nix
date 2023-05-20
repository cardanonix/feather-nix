{ config, pkgs, ... }:

let
  username = "harryprayiv";
  homeDirectory = "/Users/${username}";
  configHome = "${homeDirectory}/.config";
  
  specialArgs.ultraHD = false;

  # # workaround to open a URL in a new tab in the specific firefox profile
  # work-browser = pkgs.callPackage .././programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    aalib                # make ASCI text 
    bash
    any-nix-shell        # fish support for nix shell
    asciinema            # record the terminal
    binutils-unwrapped   # fixes the `ar` error required by cabal
    bc                   # required for Cardano Guild gLiveView
    cachix               # nix caching
    # calibre              # e-book reader
    curl                 # An old classic
    dhall                # Exotic, Nix-like configuration language
    dconf2nix            # dconf (gnome) files to nix converter
    dmenu                # application launcher
    duf                  # disk usage/free utility
    exa                  # a better `ls`
    fd                   # "find" for files
    glow                 # terminal markdown viewer
    hyperfine            # command-line benchmarking tool
    # insomnia             # rest client with graphql support
    jmtpfs               # mount mtp devices
    killall              # kill processes by name
    #libreoffice          # office suite
    ncdu                 # disk space info (a better du)
    # nfs-utils            # utilities for NFS
    # ngrok                # secure tunneling to localhost
    nix-index            # locate packages containing certain nixpkgs
    # md-toc               # generate ToC in markdown files

    # obsidian             # note taking/mind mapping
    prettyping           # a nicer ping
    ranger               # terminal file explorer
    ripgrep              # fast grep
    rnix-lsp             # nix lsp server

    #tex2nix              # texlive expressions for documents
    tldr                 # summary of a man page
    tree                 # display files in a tree view
    lorri                # needed for direnv
    ihp-new              # Haskell web framework (the Django of Haskell)
    python3Packages.ipython
    srm
    pinentry

    #  Messaging and Social Networks
    # element-desktop      # matrix client
    # discord              # discord app (breaks often)
    # tdesktop             # telegram messaging client
    # slack                # slack messaging client
    # tootle               # mastodon client

    #  Security
    rage                 # encryption tool for secrets management
    keepassxc            # Security ##
    gnupg                # Security ##
    # ledger-live-desktop  # Ledger Nano X Support for NixOS
    bitwarden-cli        # command-line client for the password manager
    mr
  ];

  haskellPkgs = with pkgs.haskellPackages; [
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

in

{
  programs.home-manager.enable = true;
  
  imports = builtins.concatMap import [
    # ./modules
    ./programs
    # ./scripts
    # ./services
    # ./themes
  ];

  home = {

    inherit username homeDirectory;
    stateVersion = "22.11";

    packages = defaultPkgs 
            ++ haskellPkgs; 

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      # CARDANO_NODE_SOCKET_PATH = "/var/lib/cardano-node/db-mainnet/node.socket";
    };
  };
  
  # restart services on change
  # systemd.user.startServices = "sd-switch";

  # xsession.numlock.enable = true;
  
  # notifications about home-manager news
  news.display = "silent";
}
