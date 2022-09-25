{ inputs, system, ... }:

let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
in
{ 
  onyxTower = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/onyxTower
      ../system/configuration.nix
    ];
  };
  plutusVM = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/plutusVM
      ../system/configuration.nix
    ];
  };
  dell-xps = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/dell-xps
      ../system/configuration.nix
    ];
  };j
  tongfang-amd = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../system/machine/tongfang-amd
      ../system/configuration.nix
    ];
  };
}
