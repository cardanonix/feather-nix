{ inputs, system, ... }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
pkgs.mkShell {
  name = "installation-shell";
  buildInputs = with pkgs; [ wget s-tar ];
}