{pkgs, ...}: {
  programs.strawberry = {
    enable = false;
    xdg.configFile."strawberry.conf".source = ./strawberry.conf;
    home.file.".strawberry.conf".text = ''
      set auto-load safe-path /nix/store
    '';
  };
}
