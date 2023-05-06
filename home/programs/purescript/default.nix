{ config, lib, pkgs, inputs, ... }:
let 

  purescriptPkgs = with pkgs; [
    # purescript
    # purenix
    # spago
    nodejs
  ];

  hsklPkgs = with pkgs.haskellPackages; [
    purescript
    purenix
    spago
    # purescript-bridge_0_15_0_0 #Generate PureScript data types from Haskell data types
    # yesod-purescript
    # hs2ps #translate haskell types to Purescript
    # dovetail #PureScript interpreter with a Haskell FFI
    # servant-purescript #Generate PureScript accessor functions for you servant API
  ];

in 

{
  home.packages = purescriptPkgs ++ hsklPkgs; 
}