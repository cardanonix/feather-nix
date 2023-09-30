let
  themes = {pkgs, ...}: {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Gruvbox";
        package = pkgs.gruvbox-dark-icons-gtk;
      };
      theme = {
        name = "Orchis-Dark";
        package = pkgs.orchis-theme;
      };
    };
  };
in [themes]
