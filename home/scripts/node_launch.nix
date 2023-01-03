{ config, pkgs, ... }:

let

  pgrep             = "${pkgs.busybox}/bin/pgrep";
  pkill             = "${pkgs.procps}/bin/pkill";
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  #noderun           = "${cardanoNodePkgs.cardano-node}/bin/cardano-node";
  #noderun           = "./cardano-node";
in
pkgs.writeShellScriptBin "node_launch" ''
  if [ "$(${pgrep} cardano-node)" ]; then
      ${pkill} -f cardano-node && sleep 10s && cardano-node run --config ${home}${config} --database-path ${home}${db_path} --topology ${topology} --host-addr 0.0.0.0 --port 3001 --socket-path ${home}${node_socket_path}      +RTS -N2 -I0 -A16m -qg -qb --disable-delayed-os-memory-return -RTS
  else
      cardano-node run --config ${home}${config} --database-path ${home}${db_path} --topology ${topology} --host-addr 0.0.0.0 --port 3001 --socket-path ${home}${node_socket_path}      +RTS -N2 -I0 -A16m -qg -qb --disable-delayed-os-memory-return -RTS
  fi
''
#TODO: node launch needs to work declaratively
#TODO: node should be a service 