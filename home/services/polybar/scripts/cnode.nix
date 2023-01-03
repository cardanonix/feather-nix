{ pkgs, ...}:

let
  pgrep  = "${pkgs.busybox}/bin/pgrep";
  pkill  = "${pkgs.procps}/bin/pkill";
  launch = "/home/bismuth/.nix-profile/bin/node_launch &";

in

  pkgs.writeShellScriptBin "cnode" ''
  case "$1" in
      --toggle)
          if [ "$(${pgrep} cardano-node)" ]; then
              ${pkill} -f cardano-node
          else
              ${launch}
          fi
          ;;
      *)
          if [ "$(${pgrep} cardano-node)" ]; then
              echo "Node On"
          else
              echo "Node Off"
          fi
          ;;
  esac  
''