{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  customFonts = pkgs.nerdfonts.override {
    fonts = [
      "JetBrainsMono"
      "Iosevka"
      "FiraMono"
      "Noto"
    ];
  };

  myfonts = pkgs.callPackage ../.././fonts/default.nix {inherit pkgs;};
in {
  imports = [
    # Window manager
    ./xmonad.nix
    ./hardware-configuration.nix
    ../.././services
  ];

  networking = {
    # Enables wireless support and openvpn via network manager.
    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    bc # required for Cardano Guild gLiveView
    git
    # brave
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

  # Making fonts accessible to applications.
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      customFonts
      font-awesome
      fira-code
      fira-code-symbols
      hasklig
      ipaexfont
      noto-fonts-cjk
      noto-fonts-emoji
      inconsolata
      myfonts.flags-world-color
      myfonts.icomoon-feather
      myfonts.cardanofont
      myfonts.monof55
    ];
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bismuth = with inputs; {
    isNormalUser = true;
    home = "/home/plutus_vm";
    uid = 1002;
    description = "PlutusVM DevConfig";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
      "scanner"
      "lp"
      "plugdev"
      "cardano-node"
      "cardano-wallet"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3Nz[...] bismuth@plutus_vm"];
  };
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "America/New_York";

  users.groups.plugdev = {};

  nixpkgs.config = {
    allowUnfree = true;
    contentAddressedByDefault = false;
    permittedInsecurePackages = [
      #"xrdp-0.9.9"
    ];
  };

  # Enable CUPS to print documents for my Brother printer.
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser];
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "plutus_vm"; # Define your hostname.
    interfaces.eno1.useDHCP = true;
  };

  /*
   swapDevices =
  [ { device = "/dev/disk/by-uuid/6d522132-d549-414a-84c9-160687b22cac"; }
  ];
  */

  # Enable sound.
  sound = {
    enable = false;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };

  fileSystems."/home/bismuth/video" = {
    device = "192.168.1.212:/volume2/video";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/Cardano" = {
    device = "192.168.1.212:/volume2/Cardano";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/Programming" = {
    device = "192.168.1.212:/volume2/Programming";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  fileSystems."/home/bismuth/plutus" = {
    device = "192.168.1.212:/volume2/homes/plutus";
    options = ["x-systemd.automount" "noauto"];
    fsType = "nfs";
  };

  services.xserver = {
    xrandrHeads = [
      {
        output = "Virtual-1";
        primary = true;
        monitorConfig = ''
          Option "PreferredMode" "1920x1080"
          Option "Position" "0 0"
        '';
      }
    ];
    resolutions = [
      {
        x = 1920;
        y = 1080;
      }
    ];
  };
  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # Flakes settings
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;
      extra-experimental-features = ["ca-derivations"];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
    };
  };

  # system.copySystemConfiguration = true;
  system.stateVersion = "23.05"; # LEAVE AS-IS (unless fresh install)
}
