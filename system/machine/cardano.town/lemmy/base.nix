{...}: {
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;

  # linode grub settings
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  # LISH Settings
  boot.kernelParams = ["console=ttyS0,19200n8"];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  # Define your hostname.
  networking.hostName = "lemmy";

  # Disable predictable interface names
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

    # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };

    # Flakes settings
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    

    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;

      # Required by Cachix to be used as non-root user
      trusted-users = [ "root" "bismuth" ];
      
      extra-experimental-features  = [ "ca-derivations" ];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      
      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs          = true;
      keep-derivations      = true;

      substituters = [
      "https://cache.nixos.org/"
      "https://cache.iog.io/"
      "https://cache.ngi0.nixos.org/"    
      ];
      trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
      ];
    };
  };
  
  nixpkgs.config = {
    # allowUnfree = true;
    contentAddressedByDefault = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
