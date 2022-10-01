{ pkgs, ... }:

# TODO: figure out how to get rounded corners working without weird artifacts in xmonad (maybe impossible).
{
  services.picom = {
    enable = true;
    backend = "glx";
    activeOpacity = 1.0;
    inactiveOpacity = 0.8;
    settings = {
          corner-radius = 10;
          blur-method = "dual_kawase";
          blur-strength = "10";
    };
        opacityRules = [ "100:name *= 'i3lock'" ];
    fade = true;
    fadeDelta = 5;
    vSync = true;
    shadow = true;
    shadowOpacity = 0.75;
    package = pkgs.picom.overrideAttrs(o: {
      src = pkgs.fetchFromGitHub {
        repo = "picom";
        owner = "ibhagwan";
        rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
        sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
      };
    });
  };
}
