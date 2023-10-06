{pkgs, ...}: let
  # obtained via `autorandr --fingerprint`
  rockPi = "00ffffffffffff004cd8000101000000081c010380331d782ed945a2554da027125054bfef80b300a9409500904081808140714f0101023a801871382d40582c4500501d7400001e011d007251d01e206e285500c48e2100001e000000fd00184c0f531201000a2020202020000000fc00534658324b382034544f3200000147020328f44d901f041305142021220312071623097f07830100006a030c001400b82d0f0800e200cf023a801871382d40582c4500501d7400001e011d007251d01e206e285500c48e2100001e011d8018711c1620582c2500c48e2100009e8c0ad08a20e02d10103e9600138e2100001800000000000000000000000000000073";

  notify = "${pkgs.libnotify}/bin/notify-send";
in {
  programs.autorandr = {
    enable = true;

    hooks = {
      predetect = {};

      preswitch = {};

      postswitch = {
        "notify-xmonad" = ''
          ${notify} -i display "Display profile" "$AUTORANDR_CURRENT_PROFILE"
        '';

        "change-dpi" = ''
          case "$AUTORANDR_CURRENT_PROFILE" in
            rockPi)
              DPI=96
              ;;
            uHD)
              DPI=120
              ;;
            *)
              ${notify} -i display "Unknown profle: $AUTORANDR_CURRENT_PROFILE"
              exit 1
          esac

          echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
        '';
      };
    };

    profiles = {
      "rockPi" = {
        fingerprint = {
          HDMI-1 = rockPi;
        };
        config = {
          HDMI-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.04";
            rotate = "normal";
          };
        };
      };

      "uHD" = {
        fingerprint = {
          HDMI-1 = uhdId;
        };

        config = {
          HDMI-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "3840x2160";
            rate = "60.04";
            rotate = "normal";
          };
        };
      };
    };
  };
}
