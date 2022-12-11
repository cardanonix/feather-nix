{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
      haskell.haskell
      justusadam.language-haskell
      arrterian.nix-env-selector
      pinage404.nix-extension-pack incorporate
      jnoortheen.nix-ide
      arcticicestudio.nord-visual-studio-code
      gruntfuggly.todo-tree
      ];
  };
}  