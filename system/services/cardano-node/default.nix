{ config, pkgs, lib, inputs, ... }: 

/*  
some tweaks I will need to implement:
TODO: make sure that the NAS is mounted before writing since I write to a NAS mounted to the same place as the node mounts by default  
I'm assuming I just add something to "systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];"
TODO: learn to either control scope or create a new user and group that my main user is part of as well.  
Currently this systemd service is too confined in the system and I wish I could control it natively from the Home Manager part of my config
TODO: gLIveView
TODO: Prometheus
TODO: Grafana
TODO: Cardano Wallet
*/
let
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  nodeconfig        = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  node_socket_path  = "/home/bismuth/Cardano/cardano-node/db-mainnet/node.socket";
  db_path           = "/home/bismuth/Cardano/cardano-node/db-mainnet";


in
{   
  services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
    enable = true;
    package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
    systemdSocketActivation = true;
    environment = "mainnet";
    environments = inputs.cardano-node.environments.x86_64-linux;
    rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
    topology = "${topology}";
    nodeConfigFile = "${nodeconfig}";
    databasePath = "${db_path}";
    socketPath = "${node_socket_path}";
    # useNewTopology = true;
    # nodeId = 2;
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
  
  systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
  systemd.services.cardano-node.after = lib.mkForce [ "/home/bismuth/Cardano.mount" "network-online.target" "cardano-node.socket" ];
  
  nixpkgs.overlays = [ inputs.cardano-node.overlay ];
  
  environment.systemPackages = with inputs.cardano-node.packages.x86_64-linux; [
    # bech32
    # cabalProjectRegenerate
    cardano-cli
    # cardano-node-chairman
    # cardano-ping
    # cardano-submit-api
    # cardano-testnet
    # cardano-topology
    # cardano-tracer
    # chain-sync-client-with-ledger-state
    # db-analyser
    # db-converter
    # db-synthesizer
    # ledger-state
    # locli
    # plutus-example
    # scan-blocks
    # scan-blocks-pipelined
    # tx-generator
  ];

  users.groups.cardano-node.gid = 10016;
  
  environment.variables = {
    CARDANO_NODE_SOCKET_PATH = "/home/bismuth/Cardano/cardano-node/db-mainnet/node.socket";
  };

  
}
