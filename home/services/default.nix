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
  #./cardano-node   # TODO: fix cardano node service
  #./cardano-wallet # TODO: fix cardano wallet
  ./networkmanager
  ./picom
  ./polybar
  ./screenlocker
  ./redshift
  ./betterlockscreen #TODO: fix screen locker
  ./udiskie
  more
]