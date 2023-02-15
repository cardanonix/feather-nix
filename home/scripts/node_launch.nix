{ config, pkgs, ... }:

let

  pgrep             = "${pkgs.busybox}/bin/pgrep";
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  cowsay            = "${pkgs.cowsay}/bin/cowsay";
in
pkgs.writeShellScriptBin "node_launch" ''
  if [ "$(${pgrep} cardano-node)" ]; then
      echo "Killing Node!" && systemctl reload-or-restart cardano-node.service
  else
      echo "Node Launching!" && systemctl start cardano-node.service
  fi
''