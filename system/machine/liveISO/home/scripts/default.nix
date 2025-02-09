let
  scripts = {
    config,
    pkgs,
    ...
  }: let
    gen-ssh-key = pkgs.callPackage ./gen-ssh-key.nix {inherit pkgs;};
    quote = pkgs.callPackage ./quotify.nix {inherit pkgs;};
    vpn = pkgs.callPackage ./vpn.nix {inherit pkgs;};
    hcr = pkgs.callPackage ./changes-report.nix {inherit config pkgs;};
    hms = pkgs.callPackage ./switcher.nix {inherit config pkgs;};
    kls = pkgs.callPackage ./keyboard-layout-switch.nix {inherit pkgs;};
    szp = pkgs.callPackage ./show-zombie-parents.nix {inherit pkgs;};
  in {
    home.packages = [
      hcr # home-manager changes report between generations
      gen-ssh-key # generate ssh key and add it to the system
      kls # switch keyboard layout
      szp # show zombie parents
      vpn #toggles the vpn
    ];
  };
in [scripts]
