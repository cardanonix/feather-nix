{ pkgs, ... }:

{
  xdg.configFile."betterlockscreenrc".source = ./betterlockscreenrc;
  home.file.".betterlockscreenrc".text = ''
      set auto-load safe-path /nix/store
  '';
}
#This will create symlink $XDG_CONFIG_HOME/betterlockscreen and ~/.betterlockscreenrc

