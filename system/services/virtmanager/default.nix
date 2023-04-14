{ config, lib, pkgs, inputs, ... }:
let 

  virtPackages = with pkgs; [     
    virtmanager
    qemu 
    virt-viewer 
    dnsmasq 
    vde2 
    bridge-utils 
    # iproute2 # bridge-utils is deprecated in favor of iproute2
    netcat-openbsd 
    # python 
    # python311Packages.pip 
    ebtables 
    iptables
  ];

in 

{
  environment.systemPackages =  virtPackages; 

  virtualisation.libvirtd.enable = true;

}
