{ pkgs, ...}:

let
  pgrep           = "${pkgs.busybox}/bin/pgrep";
in
  pkgs.writeShellScriptBin "cnode" ''
    if [ "$(${pgrep} cardano-node)" ]; then
        echo ""
    else
        echo "轢"
    fi
''