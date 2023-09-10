let
  more = {
    services = {
      flameshot.enable = true;
      lorri.enable = true;
    };
  };
in [
  ./dunst
  ./gpg-agent
  ./networkmanager
  ./picom
  ./polybar
  ./screenlocker
  ./redshift
  ./betterlockscreen
  ./udiskie
  ../../secrets/home_secret.nix
  more
]
