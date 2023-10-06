{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  version = "iso-23.05";
in {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ./xmonad.nix
  ];

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.enableUnstable = true;

  nixpkgs.config.allowUnfree = true;

  security = {
    sudo.wheelNeedsPassword = false;
  };

  networking.hostName = "nixos_iso";
  networking.firewall.enable = true;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # programs.adb.enable = true;
  # programs.mosh.enable = true;
  # programs.tmux.enable = true;
  # programs.tmux.shortcut = "a";
  # programs.tmux.terminal = "screen-256color";
  # programs.tmux.clock24 = true;
  # programs.bash.enable = true;

  programs.bash.enableCompletion = true;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };
  # defaultLocale = "fr_FR.UTF-8";
  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    git
    gnupg
    sudo
    unzip
    htop
    vim
    networkmanager
    alacritty
    vim
    wget
    bc
    git
    brave
    git-crypt
    gnupg
    firejail
    dnsutils
    screen
    jq
    pinentry
    srm
    gparted
    zip
  ];
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
  };

  users.extraUsers.bismuth = with inputs; {
    isNormalUser = true;
    home = "/home/plutus_vm";
    uid = 1002;
    description = "PlutusVM DevConfig";
    password = "plutus";
    extraGroups = [
      "wheel"
      "adbusers"
      "disks"
      "networkmanager"
    ];
    shell = pkgs.fish;
    # openssh.authorizedKeys.keys = ["ssh-rsa 832958SKNDIN7235098437AAJXB"];
  };

  isoImage.makeUsbBootable = true;
  isoImage.makeEfiBootable = true;
  isoImage.includeSystemBuildDependencies = true; # offline install
  isoImage.storeContents = with pkgs; [
    git
    gnupg
    unzip
    zip
    htop
    vim
    alacritty
    wget
    brave
    git-crypt
    firejail
    dnsutils
    screen
    jq
    pinentry
    srm
    gparted
  ];
  #   system.stateVersion = "23.05"; # LEAVE AS-IS (unless fresh install)
  #   system.copySystemConfiguration = true;
  # # Nix daemon config
  # nix = {
  #   # Automate garbage collection
  #   gc = {
  #     automatic = true;
  #     dates = "weekly";
  #     options = "--delete-older-than 7d";
  #   };
  #   # Flakes settings
  #   package = pkgs.nixUnstable;
  #   registry.nixpkgs.flake = inputs.nixpkgs;
  #   settings = {
  #     # Automate `nix store --optimise`
  #     auto-optimise-store = true;
  #     extra-experimental-features = ["ca-derivations"];
  #     experimental-features = ["nix-command" "flakes"];
  #     warn-dirty = false;
  #     # Avoid unwanted garbage collection when using nix-direnv
  #     keep-outputs = true;
  #     keep-derivations = true;
  #   };
  # };
}
