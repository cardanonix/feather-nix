{ config, lib, pkgs, inputs, ... }:

let
  customFonts = pkgs.nerdfonts.override {
    fonts = [
      "JetBrainsMono"
      "Iosevka"
      "FiraMono" 
      "Noto"
    ];
  };

  myfonts = pkgs.callPackage fonts/default.nix { inherit pkgs; };
in
{
  imports =
    [
      # Window manager
      ./wm/xmonad.nix
      # Binary cache
      ./cachix.nix
    ];

  networking = {
    # Enables wireless support and openvpn via network manager.
    networkmanager = {
      enable   = true;
      plugins = [ pkgs.networkmanager-openvpn ];
    };

  # disable the firewall 
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 3001 9090 3000 3100 12798 ];

    #firewall.allowedUDPPorts = [ ... ];
    
    #proxy.default = "http://user:password@proxy:port/";
    #proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable           = true;
    enableSSHSupport = true;
  };

  services = {
    # Mount MTP devices
    gvfs.enable = true;

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      allowSFTP = true;
    };
    
    # Yubikey smart card mode (CCID) and OTP mode (udev)
    pcscd.enable = true;
    udev.packages = [ pkgs.yubikey-personalization ];

    # SSH daemon.
    sshd.enable = true;

    xrdp = {
      enable = true;
      defaultWindowManager = "xmonad";
      openFirewall = true;
      #package = pkgs.xrdp.overrideAttrs (old: {
      #postInstall = old.postInstall + ''
      #echo ">>>>>>>>> INI file"
      #cat $out/etc/xrdp/xrdp.ini
      #echo "<<<<<<<<< INI file"
      #'';
      #});
    };
  };
  environment.systemPackages = with pkgs; [
      alacritty
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      bc                   # required for Cardano Guild gLiveView
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
      cups-brother-hll2375dw
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
      myfonts.flags-world-color
      myfonts.icomoon-feather
      myfonts.cardanofont
      fira-code
      fira-code-symbols
      hasklig
      ipaexfont
      noto-fonts-cjk
      noto-fonts-emoji
      inconsolata
    ];
  };
  
  programs.fish.enable = true;
  programs.zsh.enable = true;

  security = {
    # Yubikey login & sudo
    pam.yubico = {
      enable = true;
      debug = false;
      mode = "challenge-response";
    };

    # Sudo custom prompt message
    sudo.configFile = ''
      Defaults lecture=always
      Defaults lecture_file=${misc/groot.txt}
    '';
  };
    
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

  system.copySystemConfiguration = true;
  system.stateVersion = "22.11"; # LEAVE AS-IS (unless fresh install)
}
