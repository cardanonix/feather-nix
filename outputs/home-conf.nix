{ inputs, system, ... }:

with inputs;

let
  fishOverlay = f: p: {
    inherit fish-bobthefish-theme fish-keytool-completions;
  };

  cowsayOverlay = f: p: {
    cowsay = inputs.cowsay.packages.${system}.cowsay;
  };

  nautilusOverlay = f: p: {
    nautilus-gtk3 = nixpkgs-nautilus-gtk3.legacyPackages.${system}.gnome.nautilus;
  };

  gnomeOverlay = f: p: {
    gnome3 = nixpkgs-gnome3.legacyPackages.${system}.gnome.gnome3;
  };


  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
      cowsayOverlay
      fishOverlay
      nautilusOverlay
      nurpkgs.overlay
      neovim-flake.overlays.${system}.default
      (f: p: { tex2nix = tex2nix.defaultPackage.${system}; })
      ((import ../home/overlays/md-toc) { inherit (inputs) gh-md-toc; })
      (import ../home/overlays/protonvpn-gui)
      (import ../home/overlays/ranger)
      (import ../home/overlays/nautilus)
    ];
  };

  nur = import nurpkgs {
    inherit pkgs;
    nurpkgs = pkgs;
  };

  imports = [
    neovim-flake.nixosModules.${system}.hm
    ../home/home.nix
  ];

  mkHome = { ultraHD ? false }: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      extraSpecialArgs = {
        inherit ultraHD inputs;
        addons = nur.repos.rycee.firefox-addons;
      };

      modules = [{ inherit imports; }];
    }
  );
in
{
  bismuth-edp = mkHome { ultraHD = false; };
  bismuth-uhd = mkHome { ultraHD = true; };

}
