{ pkgs, ...}:

let
  pgrep           = "${pkgs.busybox}/bin/pgrep";
in
  pkgs.writeShellScriptBin "cnode" ''
    if [ "$(${pgrep} cardano-node)" ]; then
        echo "歷"
    else
        echo "轢"
    fi
''