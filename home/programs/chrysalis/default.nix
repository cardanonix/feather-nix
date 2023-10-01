{
  #   config,
  #   lib,
  #   pkgs,
  #   inputs,
  #   ...
  # }: let
  #   chrysalis = with pkgs; [
  #     chrysalis
  #   ];
  # in {
  #   home.packages = chrysalis;

  #   # home.sessionVariables = {
  #   #   # CHRYSLAISPATH = "/var/lib/cardano-node/db-mainnet/node.socket";
  #   # };
}
