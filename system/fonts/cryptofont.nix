# { lib, fetchurl }:

# let
#   pname   = "cryptofont";
#   version = "6bb9ed3466ec5a25ac173edd0353a2b5f60a985d";
# in 
#   fetchurl {
#     # name = "${pname}";
#     url = "https://github.com/monzanifabio/cryptofont/raw/62204c2afbb100ccab2fe3c6acc702149b8d89c7/fonts/cryptofont.ttf"; 

#     downloadToTemp = true;
#     recursiveHash = true;

#     postFetch = ''
#       install -D $downloadedFile $out/share/fonts/truetype/${pname}.ttf
#     '';
    
#     sha256 = null;
#   }

{ stdenv, lib }:

stdenv.mkDerivation {
  name = "cryptofont";
  src = ./cryptofont.ttf;

  phases = ["installPhase"];

  installPhase = ''
    install -D $src $out/share/fonts/truetype/cryptofont.ttf
  '';
}
