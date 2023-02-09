{ pkgs, ...}:

let
  curl  = "${pkgs.curl}/bin/curl";
  jq  = "${pkgs.jq}/bin/jq";
  sed = "${pkgs.gnused}/bin/sed";
in

  pkgs.writeShellScriptBin "fngi" ''
    fngi=$(${curl} -s "https://api.alternative.me/fng/" | ${jq} '.data[0]' | ${jq} '.value' | ${sed} 's/"//g')

    if [ -z "$fngi" ]; then
        echo "  $fngi"
    elif [ "$fngi" -ge 50 ]; then
        echo "󰇴  $fngi"
    elif [ "$fngi" -ge 1 ]; then
        echo "󰯈  $fngi"
    else
        echo "  $fngi"
    fi
  ''