{
  config,
  pkgs,
  ...
}: let
  version = "iso-23.05";
in {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    # ./xmonad.nix
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

  programs.adb.enable = true;
  programs.bash.enableCompletion = true;

  programs.fish.enable = true;
  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.gnupg.agent.pinentryFlavor = "tty";
  # console.font = "Lat2-Terminus16";
  console.keyMap = "us";
  # console.defaultLocale = "fr_FR.UTF-8";

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
    brave
    git-crypt
    firejail
    dnsutils
    screen
    jq
    srm
    gparted
    zip
  ];
  users.users.water = {
    isNormalUser = true;
    password = "water";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "adbusers"
      "disks"
      "networkmanager"
    ];
  };
  isoImage.makeUsbBootable = true;
  isoImage.makeEfiBootable = true;
  isoImage.includeSystemBuildDependencies = true; # offline install
  isoImage.storeContents = with pkgs; [
    git
    gnupg
    unzip
    htop
    vim
    git-crypt
    wget
    zip
    jq
  ];
}
