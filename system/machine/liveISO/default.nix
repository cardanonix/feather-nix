{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    #   <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    #   # Provide an initial copy of the NixOS channel so that the user
    #   # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # use the latest Linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];

  # {
  #   config,
  #   pkgs,
  #   lib,
  #   inputs,
  #   ...
  # }:
  # with lib; {
  # imports = [
  #   # ./xmonad.nix

  # ];

  # TODO: populate these from a fresh image
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/7BB3-09C5";
  #   fsType = "vfat";
  # };
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/0fddb262-13c1-46b1-9a5d-216766f47498";
  #   fsType = "ext4";
  # };
  #
  #
  #  swapDevices =
  # [ { device = "/dev/disk/by-uuid/6d522132-d549-414a-84c9-160687b22cac"; }
  # ];

  /*
     # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.water = with inputs; {
    isNormalUser = true;
    home = "/home/water";
    uid = 1002;
    description = "Water Live ISO";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lp"
      "plugdev"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3Nz[...] water@liveISO"];
  };

  users.groups.plugdev = {};

  nixpkgs.config = {
    allowUnfree = true;
    contentAddressedByDefault = false;
    permittedInsecurePackages = [
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      # availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
    # kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "liveISO"; # Define your hostname.
    interfaces.eno1.useDHCP = true;
  };

  # Enable sound.
  sound = {
    enable = false;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };

  services.xserver = {
    xrandrHeads = [
      {
        output = "HDMI-1";
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
  */

  # Nix daemon config
  # nix = with pkgs; {
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
  #     # extra-experimental-features = ["ca-derivations"];
  #     # experimental-features = ["nix-command" "flakes"];
  #     # warn-dirty = false;
  #     # Avoid unwanted garbage collection when using nix-direnv
  #     keep-outputs = true;
  #     keep-derivations = true;
  #     # Required by Cachix to be used as non-root user
  #     trusted-users = ["root" "water"];

  #     substituters = [
  #       "https://cache.nixos.org/"
  #       "https://cache.iog.io/"
  #       "https://cache.ngi0.nixos.org/"
  #     ];
  #     trusted-public-keys = [
  #       "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  #       "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  #       "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
  #       "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
  #     ];
  #   };
  # };
}
