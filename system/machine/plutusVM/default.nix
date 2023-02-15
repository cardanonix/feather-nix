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

      # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bismuth = {
      isNormalUser = true;
      home = "/home/bismuth";
      uid = 1002;
      description = "Harry Pray IV";
      extraGroups  = [ "docker" "networkmanager" "wheel" "scanner" "lp" "plugdev" "cardano-node" ];
      shell = pkgs.fish;
      # openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... alice@foobar" ];
  };

  users.groups.plugdev = {};

  networking = {
    hostName = "plutusVM"; # Define your hostname.
    interfaces.eno1.useDHCP = true;
    #interfaces.eth0.useDHCP = true;
  };

/*   swapDevices =
    [ { device = "/dev/disk/by-uuid/6d522132-d549-414a-84c9-160687b22cac"; }
    ]; */

# Enable sound.
  sound = {
    enable = false;
    mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };

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

/*   fileSystems."/home/bismuth/music" =
    { device = "192.168.1.212:/volume2/music";
      options = [ "x-systemd.automount" "noauto" ];
      fsType = "nfs";
    }; */

  services.xserver = {
    xrandrHeads = [
      { output = "Virtual-1";
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
      # Enable Docker & VirtualBox support.
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    virtualbox.host = {
      enable = false;
      enableExtensionPack = false;
    };
  };
}
