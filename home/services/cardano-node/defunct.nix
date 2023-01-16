# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, cardano-node, ... }: let
  baseCardanoContainer = {

    privateNetwork = true;
    autoStart = true;
    hostBridge = "br0";
    config = { config, pkgs, ... }: {
      # setup network
      networking.useDHCP = lib.mkForce true;
      imports = [ cardano-node.nixosModules.cardano-node ];
      networking.firewall.allowedTCPPorts = [ 3001 12798 ];
      environment = let
        basePackages = with pkgs; [
          dnsutils
          screen
          vim
          jq
        ];
        cardanoPackages = [
          cardano-node.packages.x86_64-linux.cardano-node
          cardano-node.packages.x86_64-linux.cardano-cli
        ];
      in {
        systemPackages = basePackages ++ cardanoPackages;
        variables = {
          CARDANO_NODE_SOCKET_PATH = config.services.cardano-node.socketPath;
        };
      };
      services = {
        cardano-node = {
          enable = true;
          environment = "testnet";
          package = cardano-node.packages.x86_64-linux.cardano-node;
          systemdSocketActivation = true;
          extraNodeConfig = {
            hasPrometheus = [ "::" 12798 ];
            TraceMempool = false;
            setupScribes = [{
              scKind = "JournalSK";
              scName = "cardano";
              scFormat = "ScText";
            }];
            defaultScribes = [
              [
                "JournalSK"
                "cardano"
              ]
            ];
          };
        };
      systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
      systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
    };
  };

in {
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.pool_opcert = { };
  sops.secrets.pool_vrf_skey = { };
  sops.secrets.pool_kes_skey = { };
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  boot.kernelModules = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  nix = {
    settings.sandbox = true;
    settings.cores = 4;
    settings.extra-sandbox-paths = [ "/etc/nsswitch.conf" "/etc/protocols" ];
    settings.substituters = [ "https://cache.nixos.org" "https://hydra.iohk.io" ];
    settings.trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "valaam";
    hostId = "07c7b2e8";
    bridges = {
      br0 = {
        interfaces = [ "enp4s0" ];
      };
    };
    useDHCP = false;
    interfaces.br0.useDHCP = true;
    interfaces.wlp3s0.useDHCP = true;
    networkmanager.enable = false;
    # TODO: remove when working
    #nat = {
    #  enable = true;
    #  internalInterfaces = [ "ve-+" ];
    #  externalInterface = "mv-enp4s0-host";
    #};
    #wireless = {
    #  enable = true;
    #  networks = secrets.wifiNetworks;
    #};
  };

  time.timeZone = "GMT";

  environment.variables = {
    CARDANO_NODE_SOCKET_PATH = "/relay-run-cardano/node.socket";
  };

  environment.systemPackages = with pkgs; [
    docker-compose

    wget
    vim
    screen
    gitMinimal
    pinentry
    gnupg
    cardano-node.packages.x86_64-linux.cardano-node
    cardano-node.packages.x86_64-linux.cardano-cli
    python3Packages.ipython
    srm
    jq
  ];

  