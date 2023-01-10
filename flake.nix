{
  description = "harryprayiv's Home Manager & NixOS configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-nautilus-gtk3.url = github:NixOS/nixpkgs?ref=37bd398;

    nurpkgs.url = github:nix-community/NUR;

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homeage = {
      url = github:jordanisaacs/homeage;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haskellNix = {
      url = "github:input-output-hk/haskell.nix";
      # workaround for nix 2.6.0 bug from here https://github.com/input-output-hk/haskell.nix/issues/1407
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iohkNix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = github:gvolpe/neovim-flake;
      # neovim-flake pushes its binaries to the cache using its own nixpkgs version
      # if we instead use ours, we'd be rebuilding all plugins from scratch
      #inputs.nixpkgs.follows = "nixpkgs";
    };

/*     cardano-flake = {
      url = "github:input-output-hk/cardano-node?rev=f75ed7755dc3ed77fd53c1cbbec6bf8a4f15a1b2";
      #inputs.nixpkgs.follows = "nixpkgs";
    };  */

    # Fish shell

    fish-bobthefish-theme = {
      url = github:gvolpe/theme-bobthefish;
      flake = false;
    };

    fish-keytool-completions = {
      url = github:ckipp01/keytool-fish-completions;
      flake = false;
    };

     # Cardano Node
    cardano-node = {
      url = "github:input-output-hk/cardano-node?rev=f75ed7755dc3ed77fd53c1cbbec6bf8a4f15a1b2";
      #TODO: how do I build the configuration bundle instead of just the executable inside of my config?
      #https://github.com/input-output-hk/cardano-node/blob/master/doc/getting-started/building-the-node-using-nix.md
    }; 

/*     cardano-node-process = {
      url = "github:input-output-hk/cardano-node?rev=f75ed7755dc3ed77fd53c1cbbec6bf8a4f15a1b2";
    }; 

    cardano-node-snapshot = {
      url = "github:input-output-hk/cardano-node?rev=f75ed7755dc3ed77fd53c1cbbec6bf8a4f15a1b2";
    }; 

    cardano-node-measured = {
      url = "github:input-output-hk/cardano-node?rev=f75ed7755dc3ed77fd53c1cbbec6bf8a4f15a1b2";
    }; */


    ## This pin is to prevent workbench-produced geneses being regenerated each time the node is bumped.
    cardano-node-workbench = {
      url = "github:input-output-hk/cardano-node/ed9932c52aaa535b71f72a5b4cc0cecb3344a5a3";
      # This is to avoid circular import (TODO: remove this workbench pin entirely using materialization):
      inputs.membench.url = "github:input-output-hk/empty-flake";
    };

         # Cardano Wallet
/*     cardano-wallet = {
      url = "github:input-output-hk/cardano-wallet?rev=bbf11d4feefd5b770fb36717ec5c4c5c112aca87";
    }; */

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
  };

  outputs = inputs:
    let system = "x86_64-linux";
    in
    {
/*    devShellsConfigurations = (
        import ./outputs/devShells-conf.nix {
          inherit inputs system;
        }
      ); */

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
    };
}
