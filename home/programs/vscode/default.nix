{ config, lib, pkgs, ... }:

let
  alacritty  = "${pkgs.alacritty}/bin/alacritty";
  bash = "${pkgs.bash}/bin/bash";
  #hls = "${pkgs.haskellPackages.haskell-language-server}/bin/haskell-language-server";
  hlint = "${pkgs.hlint}/bin/hlint}";
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.overrideAttrs (old: {
      buildInputs = old.buildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = old.postInstall or [] ++ [ ''
        wrapProgram $out/bin/codium --add-flags '--force-disable-user-env'
      '' ];
    });
    enableUpdateCheck = false;
    extensions = let
      loadAfter = deps: pkg: pkg.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.jq pkgs.moreutils ];

        preInstall = old.preInstall or [] ++ [ ''
          jq '.extensionDependencies |= . + $deps' \
            --argjson deps ${pkgs.lib.escapeShellArg (builtins.toJSON deps)} \
            package.json | sponge package.json
        '' ];
      });
    in
      pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "cab404";
          name = "vscode-direnv";
          version = "1.0.0";
          sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
        }
      ] ++ map (loadAfter [ "cab404.vscode-direnv" ]) (
        with pkgs.vscode-extensions; [
          mkhl.direnv
          haskell.haskell
          justusadam.language-haskell
          arrterian.nix-env-selector
          jnoortheen.nix-ide
          gruntfuggly.todo-tree
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "mrded";
            name = "railscasts";
            version = "0.0.4";
            sha256 = "sha256-vjfoeRW+rmYlzSuEbYJqg41r03zSfbfuNCfAhHYyjDc=";
          }
        ]
      );
    userSettings = {
        "update.mode" = "none";
        "window.zoomLevel" = "-2";
        "terminal.explorerKind" = "external";
        "terminal.external.linuxExec" = "${alacritty}";
        "terminal.integrated.defaultProfile.linux" = "${bash}";
        "terminal.integrated.copyOnSelection" = true;
        "nix.enableLanguageServer" = true;
        "explorer.confirmDelete" = false;
        "git.autofetch" = true;
        "git.autoStash" = true;
        "explorer.confirmDragAndDrop" = false;
        "git.enableCommitSigning" = true;
        "editor.minimap.enabled" = false;
        "diffEditor.ignoreTrimWhitespace" = false;
        "window.autoDetectColorScheme" = false;
        # "workbench.statusBar.visible" = false;
        "workbench.colorCustomizations" = { #ugly right now
          "statusBar.background" = "#252422";
          "statusBar.noFolderBackground" = "#1F1E1C";
          "statusBar.debuggingBackground" = "#1F1E1C";
          "editor.background" = "#1F1E1C";
          "statusBarItem.remoteBackground" = "#1F1E1C";
          "mergeEditor.change.background" = "#627A92";
          "mergeEditor.change.word.background" = "#252422";
          "tab.inactiveBackground" = "#252422";
          "sideBar.background" = "#252422";
          "sideBar.dropBackground" = "#252422"; 
          "input.background" =  "#252422";
          "banner.background" = "#252422";
          "minimap.background" = "#252422";
          "menu.background" =  "#252422";
          "menu.selectionBackground" =  "#252422";
          "icon.foreground" = "#FFFFFF";
          "statusBarItem.prominentBackground" = "#252422";
        };
    };
  };
}
