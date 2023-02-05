{ config, pkgs, inputs, stdenv, ... }:

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";

in
{ 
imports = [ inputs.cardano-node.nixosModules.cardano-node ];
  systemd = {
    services.cardano-node = {
      enable = true;
      package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
      #systemdSocketActivation = true;
      environment = "mainnet";
      useNewTopology = true;
      topology = "${topology}";
      nodeConfigFile = "${home}${config}";
      databasePath = "${home}${db_path}";
      socketPath = "${home}${node_socket_path}";
      rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
      #nodeId = "bismuthian Test!!!";
    };
    sockets.cardano-node.partOf = [ "cardano-node.socket" ];
    services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
  };
}


    