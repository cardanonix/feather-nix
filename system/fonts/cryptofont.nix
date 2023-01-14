{ lib, fetchurl }:

let
  pname   = "cryptofont";
  version = "6bb9ed3466ec5a25ac173edd0353a2b5f60a985d";
in 
  fetchurl {
    name = "${pname}-${version}";
    url = "https://raw.githubusercontent.com/monzanifabio/cryptofont/master/fonts/${pname}.ttf"; 

    downloadToTemp = true;
    recursiveHash = true;

    postFetch = ''
      install -D $downloadedFile $out/share/fonts/truetype/${pname}.ttf
    '';
    
    sha256 = "BGhBfOqrhSHklW5v8a2rCdubqmguXTfl27eS/3sIBkY=";
  }

