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
  #./cardano-wallet # TODO: fix cardano wallet
  ./networkmanager
  ./picom
  ./polybar
  ./screenlocker
  #./betterlockscreen #TODO: fix screen locker
  ./udiskie
  more
]