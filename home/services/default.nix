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
  /* error: The option `all-profiles-json' does not exist. Definition values:
       - In `/nix/store/prbcs3v3a12z78r2yb1sfil0arkkj3a1-source/home/services/cardano-node': <derivation all-profiles.json> */
  #./cardano-wallet # TODO: fix cardano wallet
  ./networkmanager
  ./picom
  ./polybar
  ./screenlocker
  ./redshift
  #./betterlockscreen #TODO: fix screen locker
  ./udiskie
  more
]