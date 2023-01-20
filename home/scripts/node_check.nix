{ pkgs, ...}:

let
  pgrep             = "${pkgs.busybox}/bin/pgrep";
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  config            = "/Cardano/mainnet/configuration/cardano/mainnet-config.json";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";
  cardano-cli       = "./cardano-cli";
  cowsay            = "${pkgs.cowsay}/bin/cowsay";
  #cli-path          = "/cardano_local/cardano-node/cardano-cli-build/bin";
in
pkgs.writeShellScriptBin "node_check" ''
    if [ "$(${pgrep} cardano-node)" ]; then
      ${cowsay} "Populating Path Variables:"
      export CARDANO_TOPOLOGY="${home}${topology}"
      export CARDANO_CONFIG="${home}${config}"
      export CARDANO_NODE_SOCKET_PATH=${home}${node_socket_path}
      export CARDANO_DB_PATH="${home}${db_path}"
      echo "Repopulating Path Variables:"
      echo "cardano-node app executable: ${home}${cardano-cli} Make This DECLARATIVE" && echo "node socket path: ${home}${node_socket_path}" && echo "database path: ${home}${db_path}" && echo "config file: ${home}${config}" && echo "topology: ${home}${topology}"
      echo ""
      echo ""
      echo "cli version:"
      cardano-cli --version
      echo ""
      echo ""
      echo "Checking Node:"
      cardano-cli query tip --mainnet
      echo ""
      echo ""
      echo "Checking Specific Wallet Addresses (addr1v9rve53mm803ecw2elz78e3ugjg7l9nxdl53c980e3y89ycw3e5r6):"
      cardano-cli query utxo --address addr1v9rve53mm803ecw2elz78e3ugjg7l9nxdl53c980e3y89ycw3e5r6 --mainnet
      echo ""
      echo ""
      echo "Checking Specific Wallet Addresses (addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446):"
      cardano-cli query utxo --address addr1qyk6kp3egk5458dfckjmtfrvjx59l78gx7wqjfpgrf9ga9pnmye2vcqtz6kqk3yc6fje4rkwmwh9fy469n7uhl5kc6aqece446 --mainnet
    else
      echo "轢"
    fi
''
