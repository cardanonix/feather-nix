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
      #equinusocio.vsc-material-theme
      mkhl.direnv
      haskell.haskell
      justusadam.language-haskell
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      gruntfuggly.todo-tree
      #hoovercj.haskell-linter
      ];
    userSettings = {
        "update.mode" = "none";
        "window.zoomLevel" = "-2";
        "terminal.explorerKind" = "external";
        "terminal.external.linuxExec" = "${alacritty}";
        "terminal.integrated.defaultProfile.linux" = "${bash}";
        "terminal.integrated.copyOnSelection" = true;
        "nix.enableLanguageServer" = true;
        "haskell.manageHLS" = "GHCup";
        "explorer.confirmDelete" = false;
        "git.autofetch" = true;
        "git.autoStash" = true;
        "explorer.confirmDragAndDrop" = false;
        "git.enableCommitSigning" = true;
        "editor.minimap.enabled" = false;
        "workbench.colorTheme" = "Material Theme Darker";
    };
  };
}

  