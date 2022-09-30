{ pkgs, ... }:

{
  services.screen-locker = {
    enable = true;
    inactiveInterval = 180;
    lockCmd = "${pkgs.multilockscreen}/bin/multilockscreen -l dim";
    xautolock.extraOptions = [
      "Xautolock.killer: systemctl suspend"
    ];
  };
}
