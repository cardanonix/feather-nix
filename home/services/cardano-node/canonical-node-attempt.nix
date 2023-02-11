{ config, pkgs, lib, inputs, ... }: 
let
  system            = "x86_64-linux";
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  nodeconfig        = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
in
{   
  inherit inputs;
  #inherit self inputs;
  #inherit (cardano-node.packages.${pkgs.system}) cardano-node;
  services.cardano-node = {
      enable = true;
      package = cardano-node.packages.${pkgs.system}.cardano-node;
      systemdSocketActivation = true;
      environment = "mainnet";
      environments = cardano-node.environments.x86_64-linux;
      useNewTopology = true;
      topology = "${topology}";
      nodeConfigFile = "${home}${nodeconfig}";
      databasePath = "${home}${db_path}";
      socketPath = "${home}${node_socket_path}";
      rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
      #nodeId = "bismuthian Test!!!";
  };

  home.packages = with inputs.cardano-node.packages.x86_64-linux; [
    bech32
    cabalProjectRegenerate
    cardano-cli
    cardano-node
    cardano-node-chairman
    cardano-ping
    cardano-submit-api
    cardano-testnet
    cardano-topology
    cardano-tracer
    chain-sync-client-with-ledger-state
    db-analyser
    db-converter
    db-synthesizer
    ledger-state
    locli
    plutus-example
    scan-blocks
    scan-blocks-pipelined
    tx-generator
  ];

  environment.systemPackages = with inputs.cardano-node.packages.x86_64-linux; [
    pinentry-curses
    bech32
    cardano-node
    cardano-cli
    sqlite-interactive
    srm
  ];

  environment.variables = {
    #CARDANO_NODE_SOCKET_PATH = config.services.cardano-node.socketPath;
  };
  
  users.groups.cardano-node.gid = 1002;

  systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
  systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
}