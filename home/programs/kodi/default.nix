{ pkgs, ... }:

{
  #pkgs.kodi.withPackages (exts: [ exts.amber-skin ])
  programs.kodi = {
    enable = true;
    settings.videolibrary = { 
      showemptytvshows = "true"; 
      recentlyaddeditems = "100";
    };
    sources = {
      video = {
        default = "videos";
        source = [
          { name = "Film"; path = "/home/bismuth/video/_Movies"; allowsharing = "true"; }
          { name = "New Films (HQ)"; path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Movies/10bit"; allowsharing = "true"; }
          { name = "New Films"; path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Movies/8bit"; allowsharing = "true"; }
          { name = "Episodic"; path = "/home/bismuth/video/_Episodic"; allowsharing = "true"; }
          { name = "New Episodic (HQ)"; path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Episodic/10bit"; allowsharing = "true"; }
          { name = "New Episodic"; path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Episodic/8bit"; allowsharing = "true"; }
        ];
      };
    };
  };
}
/*
/home/bismuth/video/_Music\ Videos/
/home/bismuth/video/_Overflow
/home/bismuth/video/_Shorts
/home/bismuth/video/_Sports
/home/bismuth/video/_Tutorials
/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Movies/bit/
/home/bismuth/video/_Extras/
/home/bismuth/video/HT_Profile




 <advancedsettings>
  <videodatabase>
    <type>mysql</type>
    <host>10.0.0.107</host>
    <port>3306</port>
    <user>xbmc</user>
    <pass></pass>
  </videodatabase> 
  <musicdatabase>
    <type>mysql</type>
    <host>10.0.0.107</host>
    <port>3306</port>
    <user>xbmc</user>
    <pass></pass>
  </musicdatabase>
  <videolibrary>
    <importwatchedstate>true</importwatchedstate>
    <importresumepoint>true</importresumepoint>
  </videolibrary>
</advancedsettings> */