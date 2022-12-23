{ config, lib, pkgs, ... }:

let
  alacritty  = "${pkgs.alacritty}/bin/alacritty";
  bash = "${pkgs.bash}/bin/bash";
in
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
        "terminal.explorerKind" = "external";
        "terminal.external.linuxExec" = "${alacritty}";
        "terminal.integrated.defaultProfile.linux" = "${bash}";
        "nix.enableLanguageServer" = true;
        "haskell.manageHLS" = "GHCup";
        "explorer.confirmDelete" = false;
        "git.autofetch" = true;
        "git.autoStash" = true;
        "explorer.confirmDragAndDrop" = false;
        "git.enableCommitSigning" = true;
        "editor.minimap.enabled" = false;
    };
  };
}

  