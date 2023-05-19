let
  scripts = { config, pkgs, ... }:
    let
      gen-ssh-key         = pkgs.callPackage ./gen-ssh-key.nix { inherit pkgs; };
    
    in
    {
      home.packages =
        [
          gen-ssh-key        # generate ssh key and add it to the system
        ];
    };
in [ scripts ]