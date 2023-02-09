{
  description = "harryprayiv's Home Manager & NixOS configurations";

  inputs = {

    flake-utils.url = "github:numtide/flake-utils";
    
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-nautilus-gtk3.url = github:NixOS/nixpkgs?ref=37bd398;

    nix.url = "github:NixOS/nix/2.13.2";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nurpkgs.url = github:nix-community/NUR;

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = github:gvolpe/neovim-flake;
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
    cncli.url = "github:cardano-community/cncli";

    rust-nix = {
      url = "github:input-output-hk/rust.nix/work";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #IOG Cardano-Haskell-Packages
    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };
    #not sure how this is different than CHaP but ::shrugs::
    haskellNix = {
      url = "github:input-output-hk/haskell.nix/14f740c7c8f535581c30b1697018e389680e24cb";
      # workaround for nix 2.6.0 bug from here https://github.com/input-output-hk/haskell.nix/issues/1407
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iohkNix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

     # Cardano Node
    cardano-node = {
      url = "github:input-output-hk/cardano-node?rev=8762a10efe3f9f97939e3cb05edaf04250456702";
      #TODO: how do I build the configuration bundle instead of just the executable inside of my config?
      #https://github.com/input-output-hk/cardano-node/blob/master/doc/getting-started/building-the-node-using-nix.md
    }; 

    # ## This pin is to prevent workbench-produced geneses being regenerated each time the node is bumped.
    # cardano-node-workbench = {
    #   url = "github:input-output-hk/cardano-node/8762a10efe3f9f97939e3cb05edaf04250456702";
    #   # This is to avoid circular import (TODO: remove this workbench pin entirely using materialization):
    #   inputs.membench.url = "github:input-output-hk/empty-flake";
    # };

         # Cardano Wallet
    cardano-wallet = {
      url = "github:input-output-hk/cardano-wallet?rev=bbf11d4feefd5b770fb36717ec5c4c5c112aca87";
    };

#______Cardano-Related Inputs End ________________


    # Github Markdown ToC generator
    gh-md-toc = {
      url = github:ekalinin/github-markdown-toc;
      flake = false;
    };

    # LaTeX stuff

    tex2nix = {
      url = github:Mic92/tex2nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cowsay = {
      url = github:snowfallorg/cowsay;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let 
      system = "x86_64-linux";
      ci = import ./outputs/ci.nix { inherit inputs system; };
      inherit (inputs.nixpkgs.lib) mapAttrs;
    in
    rec
    {
      homeConfigurations = (
        import ./outputs/home-conf.nix {
          inherit inputs system;
        }
      );

      nixosConfigurations = (
        import ./outputs/nixos-conf.nix {
          inherit inputs system;
        }
      );

      packages.${system} = {
        inherit (ci) metals metals-updater;
      };

      devShell.${system} = (
        import ./outputs/devShell.nix {
          inherit inputs system;
        }
      );

      checks.${system} =
        let
          os = mapAttrs (_: c: c.config.system.build.toplevel) nixosConfigurations;
          hm = mapAttrs (_: c: c.activationPackage) homeConfigurations;
        in
        os // hm;
    };    
}
