{ pkgs, ... }:

{
  xdg.configFile."i3blocks/config".source = ./betterlockscreenrc;
  home.file.".betterlockscreenrc".text = ''
      set auto-load safe-path /nix/store
  '';
}
#This will create symlink $XDG_CONFIG_HOME/i3blocks/config and ~/.gdbinit

