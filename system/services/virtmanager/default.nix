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
    # python # I already have these in my sys config
    # python311Packages.pip # I already have these in my sys config
    ebtables 
    iptables
  ];

in 

{
  environment.systemPackages =  virtPackages; 

  virtualisation.libvirtd.enable = true;
  
  users.extraUsers.bismuth.extraGroups = [ "libvirtd" ];

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
}