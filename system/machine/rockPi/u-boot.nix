final: prev: {
  ubootRockPi4 = let
    plat =
      if builtins.currentSystem == "aarch64-linux"
      then prev
      else prev.pkgsCross.aarch64-multiplatform;
  in
    plat.buildUBoot {
      defconfig = "rock-pi-4-rk3399_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      BL31 = "${plat.armTrustedFirmwareRK3399}/bl31.elf";
      filesToInstall = ["idbloader.img" "u-boot.itb" ".config"];
    };
}
