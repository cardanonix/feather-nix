{ pkgs, ... }:

{
  services.picom = {
    enable = true;
    backend = "glx";
    activeOpacity = 1.0;
    inactiveOpacity = 0.8;
    settings = {
          corner-radius = 10;
          round-borders = 2;
          blur-method = "dual_kawase";
          blur-strength = "10";
    };
        opacityRules = [ "100:name *= 'i3lock'" ];
    fade = true;
    fadeDelta = 5;
    vSync = true;
    shadow = true;
    shadowOpacity = 0.85;
    shadowExclude = [
          "bounding_shaped && !rounded_corners"
    ];
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


#TO-DO: nix-prefetch-url --unpack https://github.com/ibhagwan/picom.git
#TO DO: "c4107bb6cc17773fdc6c48bb2e475ef957513c7a" is the latest revision