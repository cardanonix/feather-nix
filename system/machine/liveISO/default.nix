{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    ./xmonad.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # TODO: these are dummy file systems, get the proper one
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/7BB3-09C5";
  #   fsType = "vfat";
  # };
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/0fddb262-13c1-46b1-9a5d-216766f47498";
  #   fsType = "ext4";
  # };

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
}
