self: super:

{
  nautilus-master = super.gnome.nautilus.overrideAttrs (old: {
    src = super.fetchgit {
      url = "https://gitlab.gnome.org/GNOME/nautilus.git";
      rev = "17d913595e1089ea6fa91c3b636194daaf5af311";
      sha256 = "sha256-qXd49NV06O4lth7/j/8T1o3j80evYX0277iLcJFaLC0=";
    };
  });

  nautilus-bin = super.writeShellScriptBin "nautilus-master" ''
    echo 'Running nautilus-master'
    ${self.nautilus-master}/bin/nautilus
  '';
}


#pasted from cardano-wallet
/*             overlays = [
              haskellNix.overlay
              iohkNix.overlays.utils
              iohkNix.overlays.crypto
              iohkNix.overlays.haskell-nix-extra
              iohkNix.overlays.cardano-lib
              # Haskell build tools
              (import ./nix/overlays/build-tools.nix)
              # Cardano deployments
              (import ./nix/overlays/cardano-deployments.nix)
              # Other packages overlay
              (import ./nix/overlays/pkgs.nix)
              # Our own utils (cardanoWalletLib)
              (import ./nix/overlays/common-lib.nix)
              overlay
            ]; */