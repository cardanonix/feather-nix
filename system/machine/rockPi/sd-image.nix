# implementation straight from here: https://gist.github.com/angerman/70c69c71bd91de3b9ea1ac1f438a8c62
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    ./configuration.nix
  ];
  # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
  # on space.
  sdImage.compressImage = false;

  system.build.sdImage = with lib; let
    rootfsImage = pkgs.callPackage <nixpkgs/nixos/lib/make-ext4-fs.nix> ({
        inherit (config.sdImage) storePaths;
        compressImage = true;
        populateImageCommands = config.sdImage.populateRootCommands;
        volumeLabel = "NIXOS_SD";
      }
      // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
        uuid = config.sdImage.rootPartitionUUID;
      });
  in
    pkgs.callPackage ({
      stdenv,
      dosfstools,
      e2fsprogs,
      mtools,
      libfaketime,
      utillinux,
      bzip2,
      zstd,
    }:
      stdenv.mkDerivation {
        name = config.sdImage.imageName;

        nativeBuildInputs = [dosfstools e2fsprogs mtools libfaketime utillinux bzip2 zstd];

        inherit (config.sdImage) compressImage;

        # do I need to change these?
        diskUUID = "A8ABB0FA-2FD7-4FB8-ABB0-2EEB7CD66AFA";
        loadUUID = "534078AF-3BB4-EC43-B6C7-828FB9A788C6";
        bootUUID = "95D89D52-CA00-42D6-883F-50F5720EF37E";
        rootUUID = "0340EA1D-C827-8048-B631-0C60D4478796";

        buildCommand = ''
          mkdir -p $out/nix-support $out/sd-image
          export img=$out/sd-image/${config.sdImage.imageName}
          echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
          if test -n "$compressImage"; then
            echo "file sd-image $img.bz2" >> $out/nix-support/hydra-build-products
          else
            echo "file sd-image $img" >> $out/nix-support/hydra-build-products
          fi
          echo "Decompressing rootfs image"
          zstd -d --no-progress "${rootfsImage}" -o ./root-fs.img

          # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
          rootSizeBlocks=$(du -B 512 --apparent-size ./root-fs.img | awk '{ print $1 }')

          # rootfs will be at offset 0x8000, so we'll need to account for that.
          # And add an additional 20mb slack at the end.
          imageSize=$((0x8000 + rootSizeBlocks * 512 + 20 * 1024 * 1024))
          truncate -s $imageSize $img

          sfdisk --no-reread --no-tell-kernel $img <<EOF
              label: gpt
              label-id: $diskUUID
              first-lba: 64
              start=64,    size=8000, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$loadUUID, name=loader1
              start=16384, size=8192, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=$bootUUID, name=loader2
              start=32768,            type=B921B045-1DF0-41C3-AF44-4C6F280D3FAE, uuid=$rootUUID, name=boot, attrs=LegacyBIOSBootable
          EOF

          # Copy the rootfs into the SD image
          eval $(partx $img -o START,SECTORS --nr 3 --pairs)
          dd conv=notrunc if=./root-fs.img of=$img seek=$START count=$SECTORS

          # Copy u-boot into the SD image
          eval $(partx $img -o START,SECTORS --nr 2 --pairs)
          dd conv=notrunc if=${pkgs.ubootRockPi4}/u-boot.itb of=$img seek=$START count=$SECTORS

          # Copy bootloader into the SD image
          eval $(partx $img -o START,SECTORS --nr 1 --pairs)
          dd conv=notrunc if=${pkgs.ubootRockPi4}/idbloader.img of=$img seek=$START count=$SECTORS

          if test -n "$compressImage"; then
              bzip2 $img
          fi
        '';
      }) {};
}
