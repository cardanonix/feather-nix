{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
      haskell.haskell
      justusadam.language-haskell
      arrterian.nix-env-selector
      #pinage404.nix-extension-pack incorporate
      jnoortheen.nix-ide
      arcticicestudio.nord-visual-studio-code
      gruntfuggly.todo-tree
      ];
     userSettings = {
      "window.zoomLevel" = "-2";
      "haskell.manageHLS" = "GHCup";
      "explorer.confirmDelete" = "false";
      "git.autofetch" = "true";
      "git.autoStash" = "true";
      "explorer.confirmDragAndDrop" = "false";
      "git.enableCommitSigning" = "true";
      "editor.minimap.enabled" = "false";
    };
  };
}  
