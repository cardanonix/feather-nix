{ config, pkgs, ... }:

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
in
pkgs.writeShellScriptBin "node_launch" ''
  cardano-node run --config ${home}${config} --database-path ${home}${db_path} --topology ${topology} --host-addr 0.0.0.0 --port 3001 --socket-path ${home}${node_socket_path}      +RTS -N2 -I0 -A16m -qg -qb --disable-delayed-os-memory-return -RTS
''
