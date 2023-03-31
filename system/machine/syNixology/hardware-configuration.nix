{ pkgs, ... }:

{
  fileSystems."/export/_FOOTAGE_ARCHIVE_" = {
    device = "/volume2/_FOOTAGE_ARCHIVE_";
    options = [ "bind" ];
  };
  fileSystems."/export/_STILLS_ARCHIVE_" = {
    device = "/volume2/_STILLS_ARCHIVE_";
    options = [ "bind" ];
  };
  fileSystems."/export/_Time_Machine_" = {
    device = "/volume2/_Time_Machine_";
    options = [ "bind" ];
  };
  fileSystems."/export/BUSINESS_AND_TAXES" = {
    device = "/volume2/BUSINESS_AND_TAXES";
    options = [ "bind" ];
  };
  fileSystems."/export/Cardano" = {
    device = "/volume2/Cardano";
    options = [ "bind" ];
  };
  fileSystems."/export/Client_Drive" = {
    device = "/volume2/Client_Drive";
    options = [ "bind" ];
  };
  fileSystems."/export/DOCUMENTS" = {
    device = "/volume2/DOCUMENTS";
    options = [ "bind" ];
  };
  fileSystems."/export/NetBackup" = {
    device = "/volume2/NetBackup";
    options = [ "bind" ];
  };
  fileSystems."/export/Programming" = {
    device = "/volume2/Programming";
    options = [ "bind" ];
  };
  fileSystems."/export/Transfers" = {
    device = "/volume2/Transfers";
    options = [ "bind" ];
  };
  fileSystems."/export/books" = {
    device = "/volume2/books";
    options = [ "bind" ];
  };
  fileSystems."/export/cardano-node" = {
    device = "/volume2/cardano-node";
    options = [ "bind" ];
  };
  fileSystems."/export/downloads" = {
    device = "/volume2/downloads";
    options = [ "bind" ];
  };
  fileSystems."/export/homes" = {
    device = "/volume2/homes";
    options = [ "bind" ];
  };
  fileSystems."/export/music" = {
    device = "/volume2/music";
    options = [ "bind" ];
  };
  fileSystems."/export/photo" = {
    device = "/volume2/photo";
    options = [ "bind" ];
  };
  fileSystems."/export/shared_photos" = {
    device = "/volume2/shared_photos";
    options = [ "bind" ];
  };
  fileSystems."/export/tester" = {
    device = "/volume2/tester";
    options = [ "bind" ];
  };
  fileSystems."/export/video" = {
    device = "/volume2/video";
    options = [ "bind" ];
  };
  fileSystems."/export/web" = {
    device = "/volume2/web";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         192.168.1.212(rw,fsid=0,no_subtree_check) 192.168.1.15(rw,fsid=0,no_subtree_check)
    /export/_FOOTAGE_ARCHIVE_ 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/_STILLS_ARCHIVE_ 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/_Time_Machine_ 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/BUSINESS_AND_TAXES 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/Cardano 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/Client_Drive 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/DOCUMENTS 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/NetBackup 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/Programming 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/Transfers 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/books 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/cardano-node 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/downloads 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/homes 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/music 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/photo 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/shared_photos 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/tester 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/video 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
    /export/web 192.168.1.212(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
  '';
  #hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}


