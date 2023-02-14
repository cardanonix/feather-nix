{ config, pkgs, inputs, lib, stdenv, ... }:
let
  inherit (inputs) cardano-node;
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  node_socket_path  = "/home/bismuth/Cardano/mainnet/db/node.socket";
  db_path           = "/home/bismuth/Cardano/mainnet/db";
  nodeconfig        = "/home/bismuth/Cardano/mainnet/configuration/cardano/mainnet-config.json";
in
{
  # imports = [ inputs.cardano-node.nixosModules ];
  services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
    enable = true;
    package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
    systemdSocketActivation = true;
    environment = "mainnet";
    useNewTopology = true;
    topology = "${topology}";
    nodeConfigFile = "${nodeconfig}";
    databasePath = "${db_path}";
    socketPath = "${node_socket_path}";
    rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
    #nodeId = "bismuthian Test!!!";
  };
}

