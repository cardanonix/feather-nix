{ config, pkgs, ... }:

{
  imports =  [
    # Hardware scan
    ./hardware-configuration.nix
  ];

 # Use the systemd-boot EFI boot loader.
  #boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usbhid" "usb_storage" "sd_mod" ];
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
    #[ { device = "/dev/disk/by-uuid/6d522132-d549-414a-84c9-160687b22cac"; }
    ];

  fileSystems."/home/bismuth/video" =
    { device = "192.168.1.212:/volume2/video";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/srv/Cardano" =
    { device = "192.168.1.212:/volume2/Cardano";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/srv/Programming" =
    { device = "192.168.1.212:/volume2/Programming";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/srv/plutus" =
    { device = "192.168.1.212:/volume2/homes/plutus";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    };

  fileSystems."/home/bismuth/music" =
    { device = "192.168.1.212:/volume2/music";
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
