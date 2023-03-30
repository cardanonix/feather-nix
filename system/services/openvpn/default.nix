{ config, pkgs, lib, inputs, ... }: 
let
    switzerland  = { config = '' config /home/bismuth/plutus/Documents/Credentials/ovpn/ovpn_udp/ch286.nordvpn.com.udp.ovpn ''; };
    # usa          = { config = '' config /root/nixos/openvpn/homeVPN.conf ''; };
    # serverVPN    = { config = '' config /root/nixos/openvpn/serverVPN.conf ''; };
    # username     = "/home/bismuth/plutus/Documents/Credentials/vpn/code";
    # password     = "/home/bismuth/plutus/Documents/Credentials/vpn/user";

in
{
  services.openvpn  = {
    enable = true;      

    # servers = ${switzerland};
  };  
}