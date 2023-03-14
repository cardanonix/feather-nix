{ config, lib, pkgs, inputs, ... }:
let 
  pythonExt = p: with p; [
    pandas
    requests
    pip
    numpy
  ];

  pythonPkgs = with pkgs ++ pythonExt; [
    (pkgs.python3.withPackages pythonExt)
  ];

in 

{
  home.packages = pythonPkgs; 
}