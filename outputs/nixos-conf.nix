{ inputs, system, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  libx = import ../lib { inherit (inputs.nixpkgs) lib; };

  lib = inputs.nixpkgs.lib.extend (_: _: {
    inherit (libx) secretManager;
  });

  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "xrdp-0.9.9"
      ];
    };
  };
in
{ 
  intelTower = nixosSystem {
    inherit lib pkgs system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/intelTower
      ../system/configuration.nix
    ];
  };
  intelNUC = nixosSystem {
    inherit lib pkgs system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/intelNUC
      ../system/configuration.nix
    ];
  };
  plutusVM = nixosSystem {
    inherit lib pkgs system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/plutusVM
      ../system/configuration.nix
    ];
  };
}