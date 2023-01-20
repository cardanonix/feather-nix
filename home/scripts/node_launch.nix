{ config, pkgs, ... }:

let

  pgrep             = "${pkgs.busybox}/bin/pgrep";
  pkill             = "${pkgs.procps}/bin/pkill";
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  #config            = "/nix/store/4b0rmqn24w0yc2yvn33vlawwdxa3a71i-config-0-0.json";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  #noderun           = "${cardanoNodePkgs.cardano-node}/bin/cardano-node";
  #noderun           = "/nix/store/3ypdm0z5rjvk0q1wnabvi2vxhiwdsl4m-cardano-node-exe-cardano-node-1.35.4/bin/cardano-node run";
  #noderun           = "./cardano-node";
  cowsay            = "${pkgs.cowsay}/bin/cowsay";
in
pkgs.writeShellScriptBin "node_launch" ''
  if [ "$(${pgrep} cardano-node)" ]; then
      ${cowsay} "Killing Node!" && ${pkill} -f cardano-node && sleep 10s && ${cowsay} "Node Relaunching!" && cardano-node run --config ${home}${config} --database-path ${home}${db_path} --topology ${topology} --host-addr 0.0.0.0 --port 3001 --socket-path ${home}${node_socket_path}      +RTS -N2 -I0 -A16m -qg -qb --disable-delayed-os-memory-return -RTS
  else
      ${cowsay} "Node Launching!" && cardano-node run --config ${home}${config} --database-path ${home}${db_path} --topology ${topology} --host-addr 0.0.0.0 --port 3001 --socket-path ${home}${node_socket_path}      +RTS -N2 -I0 -A16m -qg -qb --disable-delayed-os-memory-return -RTS
  fi
''

#TODO: node launch needs to work declaratively
#TODO: node should be a service 




# Pasted from derivation from nix-build
/* echo "Starting: /nix/store/3ypdm0z5rjvk0q1wnabvi2vxhiwdsl4m-cardano-node-exe-cardano-node-1.35.4/bin/cardano-node run"
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