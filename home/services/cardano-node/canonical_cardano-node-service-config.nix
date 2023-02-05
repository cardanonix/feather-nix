{ config, pkgs, lib, cardano-node, ... }: let
  baseCardanoContainer = {

    # privateNetwork = true;
    autoStart = true;
    # hostBridge = "br0";
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
          inputs.cardano-node.packages.x86_64-linux.cardano-node
          inputs.cardano-node.packages.x86_64-linux.cardano-cli
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
          package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
          systemdSocketActivation = true;
          # extraNodeConfig = {
          #   hasPrometheus = [ "::" 12798 ];
          #   TraceMempool = false;
          #   setupScribes = [{
          #     scKind = "JournalSK";
          #     scName = "cardano";
          #     scFormat = "ScText";
          #   }];
          #   defaultScribes = [
          #     [
          #       "JournalSK"
          #       "cardano"
          #     ]
          #   ];
          # };
        };
      };
      systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
      systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
    };
  };

in {
  environment.variables = {
    CARDANO_NODE_SOCKET_PATH = "/relay-run-cardano/node.socket";
  };

  environment.systemPackages = with pkgs; [
    inputs.cardano-node.packages.x86_64-linux.cardano-node
    inputs.cardano-node.packages.x86_64-linux.cardano-cli
  ];

  containers = {
    relay = lib.mkMerge [ baseCardanoContainer {
      bindMounts."/run/cardano-node" = { hostPath = "/relay-run-cardano"; isReadOnly = false; };
      config = {
        services.cardano-node = {
          # ipv6HostAddr = "::";
          # extraNodeConfig.TestEnableDevelopmentNetworkProtocols = true;
          # producers =  [
          #   {
          #     accessPoints = [
          #     {
          #       address = "2a07:c700:0:503::1";
          #       port = 1025;
          #     }
          #     {
          #       address = "2a07:c700:0:505::1";
          #       port = 6021;
          #     }
          #     {
          #       address = "2600:1700:fb0:fd00::77";
          #       port = 4564;
          #     }
          #     {
          #       address = "testnet.weebl.me";
          #       port = 3123;
          #     }
          #     {
          #       address = "pool.valaam.lan.disasm.us";
          #       port = 3001;
          #     }
          #   ];
          #     advertise = false;
          #     valency = 1;
          #   }
          # ];
          # publicProducers = [
          #   {
          #     accessPoints = [{
          #       address = "relays.vpc.cardano-testnet.iohkdev.io";
          #       port = 3001;
          #     }];
          #     advertise = false;
          #   }
          # ];
          useNewTopology = true;
        };
      };
    }];
  };
}