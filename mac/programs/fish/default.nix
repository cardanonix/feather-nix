{ config, pkgs, lib, ... }:

let
  fzfConfig = ''
    set -x FZF_DEFAULT_OPTS "--preview='bat {} --color=always'" \n
    set -x SKIM_DEFAULT_COMMAND "rg --files || fd || find ."
  '';

  themeConfig = ''
    set -g theme_display_date no
    set -g theme_display_git_master_branch no
    set -g theme_nerd_fonts yes
    set -g theme_newline_cursor yes
    set -g theme_color_scheme solarized
  '';

  custom = pkgs.callPackage ./plugins.nix { };

  fenv = {
    inherit (pkgs.fishPlugins.foreign-env) src;
    name = "foreign-env";
  };

  fishConfig = ''
    bind \t accept-autosuggestion
    set fish_greeting
  '' + fzfConfig + themeConfig;

  dc = "${pkgs.docker-compose}/bin/docker-compose";
in
{
  programs.fish = {
    enable = true;
    plugins = [{
        name="foreign-env";
        src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-foreign-env";
            rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
            sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
        };
    }];
    interactiveShellInit = ''
      eval (direnv hook fish)
      any-nix-shell fish --info-right | source
    '';
    shellAliases = {
      inherit dc;
      cat = "bat";
      dps = "${dc} ps";
      dcd = "${dc} down --remove-orphans";
      drm = "docker images -a -q | xargs docker rmi -f";
      du = "${pkgs.ncdu}/bin/ncdu --color dark -rr -x";
      ls = "${pkgs.exa}/bin/exa";
      ll = "ls -a";
      ".." = "cd ..";
      ping = "${pkgs.prettyping}/bin/prettyping";
      tree = "${pkgs.exa}/bin/exa -T";
      xdg-open = "${pkgs.mimeo}/bin/mimeo";
    };
    shellInit = fishConfig;
  };

  # xdg.configFile."fish/completions/keytool.fish".text = custom.completions.keytool;
  # xdg.configFile."fish/functions/fish_prompt.fish".text = custom.prompt;
}