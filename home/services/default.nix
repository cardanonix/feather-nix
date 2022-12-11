let
  more = {
    services = {
      flameshot.enable = true;
    };
  };
in
[
  ./dunst
  ./gpg-agent
  ./networkmanager
  ./picom
  ./polybar
  ./screenlocker
  #./betterlockscreen
  ./udiskie
  more
]