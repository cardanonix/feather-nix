{...}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bismuth = {
    isNormalUser = true;
    home = "/home/bismuth";
    # uid = 1002;
    # shell = pkgs.fish;
    description = "Harry Pray IV";
    extraGroups = [
      "networkmanager"
      "wheel"
      "cardano-node"
      "cardano-wallet"
    ];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3Nz[...] bismuth@intelTower"];
  };
}
