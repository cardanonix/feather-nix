{ config, lib, pkgs, inputs, ... }:
let

  lemmyPkgs = with pkgs; [
    lemmy-ui       
    lemmy-server
  ];

in 

{
  home.packages = lemmyPkgs; 

  services.settings = {

    settings = true;
    ui.package = pkgs.lemmy-ui;
    server.package = pkgs.lemmy-server;
    ui.port = 98420;
    settings.port = 69420;
    nginx.enable = false;
    enable = true;
    caddy.enable = false;
    settings.hostname = "cardano.town";
    settings.captcha.enabled = true;
    settings.captcha.difficulty.type = "medium";
    # secretFile = ;
    # database.uri = ;
    # database.createLocally = ; 

  };

  # home.sessionVariables = {
  #   RUST_BACKTRACE = "1";
  # };
}
