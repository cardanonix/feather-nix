{ config, pkgs, inputs, specialArgs, ... }:

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  
in
{
   imports = [
    inputs.cardano-node.packages.x86_64-linux
  ];
  config.services.cardano-node = {
    enable = true;
    environment = "mainnet";
    useNewTopology = true;
    topology = "${topology}";
    nodeConfigFile = "${home}${config}";
    databasePath = "${home}${db_path}";
    socketPath = "${home}${node_socket_path}";
    #nodeId = "bismuthian Test!!!";
    rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ];
  };
}
