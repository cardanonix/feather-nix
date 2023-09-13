{pkgs, ...}: let
  systemctl = "${pkgs.systemctl}/bin/systemctl";
  vpn_name = "myvpn";
  openvpn = "${pkgs.openvpn}/bin/openvpn";
in
  pkgs.writeShellScriptBin "run_vpn" ''

    if ${systemctl} is-active "openvpn@${vpn_name}.service" > /dev/null; then
        sudo ${systemctl} net.ipv6.conf.all.disable_ipv6=0
        sudo ${systemctl} stop "openvpn@${vpn_name}.service"
    else
        sudo systemctl net.ipv6.conf.all.disable_ipv6=1
        # sudo ${systemctl} start "openvpn@${vpn_name}.service"
        sudo ${openvpn} ~/plutus/Documents/Credentials/vpn/ch286.nordvpn.com.udp.ovpn
    fi
  ''
