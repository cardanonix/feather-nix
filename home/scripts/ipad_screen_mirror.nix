{ config, pkgs, ... }:


#  tutorial here: https://taoa.io/posts/Setting-up-ipad-screen-mirroring-on-nixos/
let
  profiles = "/nix/var/nix/profiles/per-user/${config.home.username}/home-manager-*-link";
  local_cidr = "${1:-"192.168.0.0/16"}";
  awk = "${pkgs.awk}/bin/awk";
  grep = "${pkgs.grep}/bin/grep";
  #iptables = "${pkgs.iptables}/bin/iptables";
  head = "${pkgs.head}/bin/head";

in 
pkgs.writeShellScriptBin "ipad_screen_mirror" ''
    #! /usr/bin/env nix-shell
    #! nix-shell --quiet -p uxplay -i bash

    set -ueo pipefail

    ## Clear any existing "DROP ME" rules
    ## ref: https://stackoverflow.com/a/63855690/12393422
    while sudo iptables -L -n --line-number | grep "DROP ME" > /dev/null; do
      sudo iptables -D INPUT $(sudo iptables -L -n --line-number | grep "DROP ME" | head -1 | awk '{print $1}');
    done


    LOCAL_CIDR=${1:-"192.168.0.0/16"}

    open-port-tcp() {
      local port=$1
      echo "Opening tcp port $port from local_cidr ..."
      sudo iptables \
          -I INPUT \
          -p tcp \
          -s ${local_cidr} \
          --dport $port \
          -j ACCEPT \
          -m comment --comment "DROP ME"
    }

    close-port-tcp() {
      local port=${1:-0}
      echo "Closing tcp port $port from ${local_cidr} ..."
      sudo iptables \
          -D INPUT \
          -p tcp \
          -s ${local_cidr} \
          --dport $port \
          -j ACCEPT \
          -m comment --comment "DROP ME"
    }

    open-port-udp() {
      local port=$1
      echo "Opening udp port $port from ${local_cidr} ..."
      sudo iptables \
          -I INPUT \
          -p udp \
          -s ${local_cidr} \
          --dport $port \
          -j ACCEPT \
          -m comment --comment "DROP ME"
    }

    close-port-udp() {
      local port=${1:-0}
      echo "Closing udp port $port from ${local_cidr} ..."
      sudo iptables \
          -D INPUT \
          -p udp \
          -s ${local_cidr} \
          --dport $port \
          -j ACCEPT \
          -m comment --comment "DROP ME"
    }

    open-port-tcp 7100
    open-port-tcp 7000
    open-port-tcp 7001
    open-port-udp 6000
    open-port-udp 6001
    open-port-udp 7011

    # Ensure port closes if error occurs.
    trap "close-port-tcp 7100 && \
          close-port-tcp 7000 && \
          close-port-tcp 7001 && \
          close-port-udp 6000 && \
          close-port-udp 6001 && \
          close-port-udp 7011
          " EXIT

    uxplay -p
''