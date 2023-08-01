{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.stable.legacyPackages.${pkgs.system});
  baseDir = "BraveSoftware/Brave-Browser";
in
  import ./install-ext.nix {inherit baseDir;}
  {
    programs.brave = {
      enable = true;
    };
  }
