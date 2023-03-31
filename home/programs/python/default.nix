{ config, lib, pkgs, inputs, ... }:
let 
  pythonExt = p: with p; [
    pandas
    requests
    pip
    numpy
    packaging
  ];

  pythonPkgs = with pkgs ++ pythonExt; [
    (pkgs.python3.withPackages pythonExt)
  ];

  pythonStuff = with pkgs; [
    poetry
  ];

in 

{
  home.packages = pythonPkgs ++ pythonStuff; 
}