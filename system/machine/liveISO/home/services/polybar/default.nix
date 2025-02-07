{
  config,
  pkgs,
  specialArgs,
  inputs,
  ...
}: let
  browser = "${pkgs.brave}/bin/brave";

  terminal = "${pkgs.alacritty}/bin/alacritty";

  openCalendar = "${pkgs.xfce.orage}/bin/orage";

  uhdBar = pkgs.callPackage ./bar.nix {};

  hdBar = pkgs.callPackage ./bar.nix {
    font0 = 10;
    font1 = 12;
    font2 = 15;
    font3 = 14;
    font4 = 5;
    font5 = 10;
    font6 = 14;
    font7 = 8;
    font8 = 12;
  };

  mainBar =
    if specialArgs.ultraHD
    then uhdBar
    else hdBar;

  xdgUtils = pkgs.xdg-utils.overrideAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [pkgs.makeWrapper];
      postInstall =
        old.postInstall
        + "\n"
        + ''
          wrapProgram $out/bin/xdg-open --suffix PATH : /run/current-system/sw/bin --suffix BROWSER : ${browser}
        '';
    }
  );

  openGithub = "${xdgUtils}/bin/xdg-open https\\://github.com/notifications";

  mypolybar = pkgs.polybar.override {
    alsaSupport = true;
    githubSupport = true;
    mpdSupport = true;
    pulseSupport = true;
  };

  # theme adapted from: https://github.com/adi1090x/polybar-themes#-polybar-5
  bars = builtins.readFile ./bars.ini;
  colors = builtins.readFile ./colors.ini;
  mods1 = builtins.readFile ./modules.ini;
  mods2 = builtins.readFile ./user_modules.ini;

  bluetoothScript = pkgs.callPackage ./scripts/bluetooth.nix {};
  klsScript = pkgs.callPackage ../../scripts/keyboard-layout-switch.nix {inherit pkgs;};
  monitorScript = pkgs.callPackage ./scripts/monitor.nix {};
  mprisScript = pkgs.callPackage ./scripts/mpris.nix {};
  networkScript = pkgs.callPackage ./scripts/network.nix {};
  vpnToggleScript = pkgs.callPackage ../../scripts/vpn.nix {inherit pkgs;};
  vpnStatus = pkgs.callPackage ./scripts/vpnStatus.nix {};

  bctl = ''
    [module/bctl]
    type = custom/script
    exec = ${bluetoothScript}/bin/bluetooth-ctl
    tail = true
    click-left = ${bluetoothScript}/bin/bluetooth-ctl --toggle &
  '';

  cal = ''
    [module/clickable-date]
    inherit = module/date
    label = %{A1:${openCalendar}:}%time%%{A}
  '';

  github = ''
    [module/clickable-github]
    inherit = module/github
    token = ''${file:${config.xdg.configHome}/secrets/github}
    user = bismuth
    label = %{A1:${openGithub}:}  %notifications%%{A}
  '';

  keyboard = ''
    [module/clickable-keyboard]
    inherit = module/keyboard
    label-layout = %{A1:${klsScript}/bin/kls:}  %layout% %icon% %{A}
  '';

  mpris = ''
    [module/mpris]
    type = custom/script

    exec = ${mprisScript}/bin/mpris
    tail = true

    label-maxlen = 50

    interval = 2
    format =   <label>
    format-padding = 2
  '';

  vpn = ''
    [module/vpn]
    type = custom/script

    exec = ${vpnStatus}/bin/vpn_status

    interval = 4
    format = "%{T7}<label>"
    content-foreground = ''${color.lbshade4}
    format-padding = 0
    click-left = "${terminal} --hold -e ${vpnToggleScript}/bin/vpn"
  '';

  xmonad = ''
    [module/xmonad]
    type = custom/script
    exec = ${pkgs.xmonad-log}/bin/xmonad-log
    label-maxlen = 318
    tail = true
  '';

  customMods = mainBar + bctl + cal + github + keyboard + mpris + xmonad + vpn;
in {
  home.packages = with pkgs; [
    font-awesome # awesome fonts
    material-design-icons # fonts with glyphs
    xfce.orage # lightweight calendar
  ];

  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    extraConfig = bars + colors + mods1 + mods2 + customMods;
    script = ''
      export MONITOR=$(${monitorScript}/bin/monitor)
      echo "Running polybar on $MONITOR"
      export ETH_INTERFACE=$(${networkScript}/bin/check-network eth)
      export WIFI_INTERFACE=$(${networkScript}/bin/check-network wifi)
      echo "Network interfaces $ETH_INTERFACE & $WIFI_INTERFACE"
      polybar top 2>${config.xdg.configHome}/polybar/logs/top.log & disown
      polybar bottom 2>${config.xdg.configHome}/polybar/logs/bottom.log & disown
    '';
  };
}
