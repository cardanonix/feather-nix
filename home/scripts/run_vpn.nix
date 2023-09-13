{pkgs, ...}: let
  sysctl = "${pkgs.sysctl}/bin/sysctl";
  vpn_name = "myvpn";
  openvpn = "${pkgs.openvpn}/bin/openvpn";
in
  pkgs.writeShellScriptBin "run_vpn" ''

    if ${sysctl} is-active "openvpn@${vpn_name}.service" > /dev/null; then
        sudo ${sysctl} net.ipv6.conf.all.disable_ipv6=0
        sudo ${sysctl} stop "openvpn@${vpn_name}.service"
    else
        sudo systemctl net.ipv6.conf.all.disable_ipv6=1
        # sudo ${sysctl} start "openvpn@${vpn_name}.service"
        sudo ${openvpn} ~/plutus/Documents/Credentials/vpn/ch388.nordvpn.com.udp.ovpn
    fi
  ''
