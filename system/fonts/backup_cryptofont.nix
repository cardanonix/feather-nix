{ stdenv, lib }:

stdenv.mkDerivation {
  name = "Cryptofont";
  src = ./cryptofont.ttf;

  phases = ["installPhase"];

  installPhase = ''
    install -D $src $out/share/fonts/truetype/cryptofont.ttf
  '';
}
