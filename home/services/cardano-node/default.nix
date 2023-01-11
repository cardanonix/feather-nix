{ config, pkgs, lib, inputs, system, ... }:

let
  home              = "/home/bismuth";
  topology          = "/nix/store/mb0zb61472xp1hgw3q9pz7m337rmfx7f-topology.yaml";
  node_socket_path  = "/Cardano/mainnet/db/node.socket";
  db_path           = "/Cardano/mainnet/db";

in

  { config = { config, pkgs, ... }: {
      imports = [ inputs.cardano-node.nixosModules.cardano-node ];
/*       environment = let
        basePackages = with pkgs; [
          dnsutils
          screen
          vim
          jq
        ];
        cardanoPackages = [
          cardano-node.packages.x86_64-linux.cardano-node
          cardano-node.packages.x86_64-linux.cardano-cli
        ];
      in {
        systemPackages = basePackages ++ cardanoPackages;
        variables = {
          CARDANO_NODE_SOCKET_PATH = config.services.cardano-node.socketPath;
        };
      }; */
      services = {
        cardano-node = {
          enable = true;
          package = inputs.cardano-node.packages.x86_64-linux.cardano-node;          
          environment = "testnet";
          useNewTopology = true;
          topology = "${topology}";
          nodeConfigFile = "${home}${config}";
          databasePath = "${home}${db_path}";
          socketPath = "${home}${node_socket_path}";
          #nodeId = "bismuthian Test!!!";
          rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
          systemdSocketActivation = true;
/*        extraNodeConfig = {
            hasPrometheus = [ "::" 12798 ];
            TraceMempool = false;
            setupScribes = [{
              scKind = "JournalSK";
              scName = "cardano";
              scFormat = "ScText";
            }];
            defaultScribes = [
              [
                "JournalSK"
                "cardano"
              ]
            ];
          }; */
        };
/*         promtail = {
          enable = true;
          configuration = {
            server = {
              http_listen_port = 28183;
              grpc_listen_port = 0;
            };

            positions = {
              filename = "/tmp/positions.yaml";
            };

            clients = [{
              # TODO: get address of host running container
              url = "http://10.40.33.21:3100/loki/api/v1/push";
            }];

            scrape_configs = [{
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  # TODO: get container name to prevent clashing and make it easier to query
                  host = "container_name";
                };
              };
              relabel_configs = [{
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }];
            }];
          };
        }; */
      };
      systemd.sockets.cardano-node.partOf = [ "cardano-node.socket" ];
      systemd.services.cardano-node.after = lib.mkForce [ "network-online.target" "cardano-node.socket" ];
    };
  }