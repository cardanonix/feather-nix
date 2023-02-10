{ config, lib, pkgs, system, stdenv, ... }:
let 

username = "bismuth";
homeDirectory = "/home/${username}";
configHome = "${homeDirectory}/.config";
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy = {
      url = "github:input-output-hk/deploy-rs";
      inputs.nixpkgs.follows = "fenix/nixpkgs";
      inputs.fenix.follows = "fenix";
    };
    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };
    haskellNix = {
      url = "github:input-output-hk/haskell.nix/14f740c7c8f535581c30b1697018e389680e24cb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iohkNix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cardano-node = {
      url = "github:input-output-hk/cardano-node?rev=8762a10efe3f9f97939e3cb05edaf04250456702";
    }; 
    cardano-wallet = {
      url = "github:input-output-hk/cardano-wallet?rev=bbf11d4feefd5b770fb36717ec5c4c5c112aca87";
    };
    gh-md-toc = {
      url = github:ekalinin/github-markdown-toc;
      flake = false;
    };
  };
  programs.home-manager.enable = true;

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory inputs;
    stateVersion = "22.11";
    packages = with inputs.cardano-node.packages.x86_64-linux; [     
      bech32
      cabalProjectRegenerate
      cardano-cli
      cardano-node
      cardano-node-chairman
      cardano-ping
      cardano-submit-api
      cardano-testnet
      cardano-topology
      cardano-tracer
      chain-sync-client-with-ledger-state
      db-analyser
      db-converter
      db-synthesizer
      ledger-state
      locli
      plutus-example
      scan-blocks
      scan-blocks-pipelined
      tx-generator
    ]; 

    services.cardano-node = with inputs.cardano-node.nixosModules.cardano-node; {
      enable = true;
      package = inputs.cardano-node.packages.x86_64-linux.cardano-node;
      systemdSocketActivation = true;
      environment = "mainnet";
      useNewTopology = true;
      topology = "${topology}";
      nodeConfigFile = "${nodeconfig}";
      databasePath = "${db_path}";
      socketPath = "${node_socket_path}";
      rtsArgs = [ "-N2" "-I0" "-A16m" "-qg" "-qb" "--disable-delayed-os-memory-return" ]; 
    };
    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
      CARDANO_NODE_SOCKET_PATH = "/home/bismuth/Cardano/mainnet/db/node.socket";
    };
  };

  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
    ];
  };
in
{
  mkHome = { ultraHD ? false }: (
      programs.home-manager.lib.homeManagerConfiguration rec {
        inherit pkgs;
        extraSpecialArgs = {
          inherit ultraHD inputs;
        };
        modules = [{ inherit home; }];
      }
  );
}
  mkHome { ultraHD = false; }


