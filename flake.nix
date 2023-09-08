{
  description = "harryprayiv's Home Manager & NixOS configurations";

  # Inputs are how Nix can use code from outside the flake during evaluation.
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "nixpkgs/nixos-unstable";

    stable.url = "github:NixOS/nixpkgs/nixos-23.05-small";

    nixpkgs-nautilus-gtk3.url = github:NixOS/nixpkgs?ref=37bd398;

    nix.url = "github:NixOS/nix/2.13.2";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nurpkgs.url = github:nix-community/NUR;

    # flatpak = {
    #   url = "https://flathub.org/repo/flathub.flatpakrepo";
    #   flake = false;
    # };

    # flathub = {
    #   url = github:flathub/flathub;
    #   # inputs.nixpkgs.follows = "flatpak/nixpkgs"; #????
    #   flake = false;
    # };

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = github:Cardano-on-Nix/neovim-flake;
      # neovim-flake pushes its binaries to the cache using its own nixpkgs version
      # if we instead use ours, we'd be rebuilding all plugins from scratch
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fish shell
    fish-bobthefish-theme = {
      url = github:harryprayiv/theme-bobthefish;
      flake = false;
    };

    fish-keytool-completions = {
      url = github:ckipp01/keytool-fish-completions;
      flake = false;
    };

    # Github Markdown ToC generator
    gh-md-toc = {
      url = github:ekalinin/github-markdown-toc;
      flake = false;
    };

    statix = {
      url = github:nerdypepper/statix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cowsay = {
      url = github:snowfallorg/cowsay;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #______Cardano-Related Inputs

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.url = "github:nix-community/fenix";

    deploy = {
      url = "github:input-output-hk/deploy-rs";
      inputs.nixpkgs.follows = "fenix/nixpkgs";
      inputs.fenix.follows = "fenix";
    };

    cncli = {
      url = "github:cardano-community/cncli?rev=e2c0409628b4a6ba1205ecae8729cb703cbc5c12";
    };

    rust-nix = {
      url = "github:input-output-hk/rust.nix/work";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #IOG Cardano-Haskell-Packages
    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };

    haskellNix = {
      url = "github:input-output-hk/haskell.nix/b90fbaa272a6d17ddc21164ca3056e1618feafcd";
      # workaround for nix 2.6.0 bug from here https://github.com/input-output-hk/haskell.nix/issues/1407
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iohkNix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cardano-node = {
      url = "github:input-output-hk/cardano-node?rev=d2d90b48c5577b4412d5c9c9968b55f8ab4b9767";
      #TODO: how do I build the configuration bundle instead of just the executable inside of my config?
      #https://github.com/input-output-hk/cardano-node/blob/master/doc/getting-started/building-the-node-using-nix.md
    };
  };

  # Outputs are the public-facing interface to the flake.
  outputs = inputs: let
    inherit (inputs.nixpkgs.lib) mapAttrs;
    inherit inputs;
    system = "x86_64-linux";

    ci = with inputs system; (
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;

          overlays = [
            neovim-flake.overlays.${system}.default
          ];
        };
      in {
        metals = pkgs.callPackage ./home/programs/neovim-ide/metals.nix {};
        metals-updater = pkgs.callPackage ./home/programs/neovim-ide/update-metals.nix {};
      }
    );
  in rec
  {
    homeConfigurations = with inputs; (
      let
        inherit (inputs) cardano-node;
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

        cardanoOverlay = f: p: {
          cardano = inputs.cardano-node.packages.${system}.cardano-node;
        };

        pkgs = import nixpkgs {
          inherit system;

          config.allowUnfree = true;

          overlays = [
            cardanoOverlay
            cowsayOverlay
            fishOverlay
            nautilusOverlay
            nurpkgs.overlay
            neovim-flake.overlays.${system}.default
            (f: p: {tex2nix = tex2nix.defaultPackage.${system};})
            ((import ./home/overlays/md-toc) {inherit (inputs) gh-md-toc;})
            (import ./home/overlays/protonvpn-gui)
            (import ./home/overlays/ranger)
            (import ./home/overlays/nautilus)
          ];
        };

        nur = import nurpkgs {
          inherit pkgs;
          nurpkgs = pkgs;
        };

        imports = [
          # inputs.cardano-node.nixosModules.cardano-node
          #inputs.cardano-wallet.nixosModules.cardano-wallet
          neovim-flake.nixosModules.${system}.hm
          ./home/home.nix
        ];

        # imports = [
        #   neovim-flake.nixosModules.${system}.hm
        #   ./home/slim/home.nix
        # ];

        mkHome = {ultraHD ? false}: (
          home-manager.lib.homeManagerConfiguration rec {
            inherit pkgs;

            extraSpecialArgs = {
              inherit ultraHD inputs;
              addons = nur.repos.rycee.firefox-addons;
            };
            modules = [{inherit imports;}];
          }
        );

        mkSlim = {ultraHD ? false}: (
          home-manager.lib.homeManagerConfiguration rec {
            inherit pkgs;

            extraSpecialArgs = {
              inherit ultraHD inputs;
              addons = nur.repos.rycee.firefox-addons;
            };
            modules = [
              (import ./slim/home.nix)
              neovim-flake.nixosModules.${system}.hm
            ];
          }
        );
      in {
        vm-home = mkSlim {ultraHD = false;};
        bismuth-edp = mkHome {ultraHD = false;};
        bismuth-uhd = mkHome {ultraHD = true;};
      }
    );
    nixosConfigurations = (
      let
        inherit (inputs.nixpkgs.lib) nixosSystem;

        libx = import ./lib {inherit (inputs.nixpkgs) lib;};

        lib = inputs.nixpkgs.lib.extend (_: _: {
          inherit (libx) secretManager;
        });

        pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in {
        intelTower = nixosSystem {
          inherit lib pkgs system;
          specialArgs = {inherit inputs;};
          modules = [
            inputs.cardano-node.nixosModules.cardano-node
            # inputs.cardano-wallet.nixosModules.cardano-wallet
            ./system/machine/intelTower
            ./system/configuration.nix
          ];
        };
        intelNUC = nixosSystem {
          inherit lib inputs pkgs system;
          specialArgs = {inherit inputs;};
          modules = [
            inputs.cardano-node.nixosModules.cardano-node
            ./system/machine/intelNUC
            ./system/configuration.nix
          ];
        };
        plutus_vm = nixosSystem {
          inherit lib pkgs system;
          specialArgs = {inherit inputs;};
          modules = [
            inputs.cardano-node.nixosModules.cardano-node
            ./system/machine/plutus_vm
            ./system/configuration.nix
          ];
        };
      }
    );

    packages.${system} = {
      inherit (ci) metals metals-updater;
    };

    devShell.${system} = let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
      pkgs.mkShell {
        name = "install-shell";
        buildInputs = with pkgs; [wget s-tar];
      };

    checks.${system} = let
      os = mapAttrs (_: c: c.config.system.build.toplevel) nixosConfigurations;
      hm = mapAttrs (_: c: c.activationPackage) homeConfigurations;
    in
      os // hm;
  };
}
