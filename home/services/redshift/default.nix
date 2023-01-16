{ config, pkgs, callPackage, ... }: {

  services.redshift = {
    enable = true;
    
    settings.redshift = {
      # Note the string values below.
      brightness-day = "1";
      brightness-night = "1";
    };

    temperature = {
      day = 6000;
      night = 2900;
    };
    
    provider = "manual";
    latitude = 42.43632586235741;
    longitude = -71.08012453940802;
  };
}