{ config, pkgs, lib, inputs, system, ... }:

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  #cfg               = config.services.cardano-node; */
  
in

{   
  imports = [
    inputs.cardano-flake.nixosModules
  ];

  services.cardano-node.cardanoNodePackages = lib.mkDefault (mkCardanoNodePackages flake.project.${pkgs.system});
  
  config.services.cardano-node = {
    enable = true;
    #executable = "exec config.services.cardano-node.pkgs.cardanoNodePackages.cardano-node/bin/cardano-node";
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
