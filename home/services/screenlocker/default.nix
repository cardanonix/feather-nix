{ pkgs, ... }:

{
  services.screen-locker = {
    enable = true;
    inactiveInterval = 180;
    lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
    xautolock.extraOptions = [
      "Xautolock.locker: systemctl suspend"
    ];
  };
}