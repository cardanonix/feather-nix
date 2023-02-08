{ config, pkgs, lib, inputs, cardano-node, ... }: 

with inputs.cardano-node.nixosModules.cardano-node;

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  nodeconfig        = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
in
{ 
  config.services.cardano-node = {
      enable = true;
      package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
      systemdSocketActivation = true;
      environment = "mainnet";
      useNewTopology = true;
      topology = "${topology}";
      nodeConfigFile = "${home}${nodeconfig}";
      databasePath = "${home}${db_path}";
      socketPath = "${home}${node_socket_path}";
      rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
      #nodeId = "bismuthian Test!!!";
    };
}