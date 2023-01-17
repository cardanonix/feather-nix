{ config, pkgs, inputs, lib, cardano-node, system, callPackage, ... }:

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";

in

  {config = {
      #services.cardano-node = {
      import = [ inputs.nixosModules.cardano-node.services.cardano-node.cardanoNodePackages  ];

      systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
      systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
      
      services = {
        cardano-node = {
          enable = true;

          package = inputs.cardano-node.packages.x86_64-linux.cardano-node;          
          #environment = "mainnet";
          #useNewTopology = true;
          topology = "${topology}";
          # nodeConfigFile = "${home}${config}";
          databasePath = "${home}${db_path}";
          socketPath = "${home}${node_socket_path}";
          nodeId = "bismuthian Test!!!";
          rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
          systemdSocketActivation = true;
        };
      };
    };
  }





/* 

  echo "Starting: /nix/store/3ypdm0z5rjvk0q1wnabvi2vxhiwdsl4m-cardano-node-exe-cardano-node-1.35.4/bin/cardano-node run"
   echo "--config /nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json"
   echo "--database-path state-node-mainnet/db-mainnet"
   echo "--topology /nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml"
   echo "--host-addr 0.0.0.0"
   echo "--port 3001"
   echo "--socket-path state-node-mainnet/node.socket"
   echo ""
   echo ""
   echo ""
   echo ""
   echo ""
   echo "+RTS"
   echo "-N2"
   echo "-I0"
   echo "-A16m"
   echo "-qg"
   echo "-qb"
   echo "--disable-delayed-os-memory-return"
   echo "-RTS"
echo "..or, once again, in a single line:"
echo "/nix/store/3ypdm0z5rjvk0q1wnabvi2vxhiwdsl4m-cardano-node-exe-cardano-node-1.35.4/bin/cardano-node run --config /nix/store/4b0rmq> */