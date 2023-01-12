{ config, pkgs, ... }:

{
  imports =  [
    # Hardware scan
    ./hardware-configuration.nix
  ];

 # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      };
    };

  networking = {
    hostName = "intelNUC"; # Define your hostname.
    interfaces.eno1.useDHCP = true;
    #interfaces.eth0.useDHCP = true;
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/8e6afd02-5fe0-4f63-9be4-c074a9f995ea"; }
    ];

  fileSystems."/home/bismuth/video" =
    { device = "192.168.1.212:/volume2/video";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/home/bismuth/Cardano" =
    { device = "192.168.1.212:/volume2/Cardano";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/home/bismuth/Programming" =
    { device = "192.168.1.212:/volume2/Programming";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/home/bismuth/plutus" =
    { device = "192.168.1.212:/volume2/homes/plutus";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/home/bismuth/music" =
    { device = "192.168.1.212:/volume2/music";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/home/bismuth/shared_photos" =
    { device = "192.168.1.212:/volume2/shared_photos";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  services.xserver = {
    xrandrHeads = [
      { output = "HDMI-1";
        primary = true;
        monitorConfig = ''
          Option "PreferredMode" "1920x1080"
          Option "Position" "0 0"
        '';
      }
    ];
    resolutions = [
      { x = 1920; y = 1080; }
    ];
  };
}
