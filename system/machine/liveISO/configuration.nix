{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  version = "iso-23.05";
in {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ./xmonad.nix
  ];

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.enableUnstable = true;

  nixpkgs.config.allowUnfree = true;

  security = {
    sudo.wheelNeedsPassword = false;
  };

  networking.hostName = "nixos_iso";
  networking.firewall.enable = true;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # programs.adb.enable = true;
  # programs.mosh.enable = true;
  # programs.tmux.enable = true;
  # programs.tmux.shortcut = "a";
  # programs.tmux.terminal = "screen-256color";
  # programs.tmux.clock24 = true;
  # programs.bash.enable = true;

  programs.bash.enableCompletion = true;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };
  # defaultLocale = "fr_FR.UTF-8";
  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    git
    gnupg
    sudo
    unzip
    htop
    vim
    networkmanager
    alacritty
    vim
    wget
    bc
    git
    brave
    git-crypt
    gnupg
    firejail
    dnsutils
    screen
    jq
    pinentry
    srm
    gparted
    zip
  ];
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
  };

  users.extraUsers.bismuth = with inputs; {
    isNormalUser = true;
    home = "/home/plutus_vm";
    uid = 1002;
    description = "PlutusVM DevConfig";
    password = "plutus";
    extraGroups = [
      "wheel"
      "adbusers"
      "disks"
      "networkmanager"
    ];
    shell = pkgs.fish;
    # openssh.authorizedKeys.keys = ["ssh-rsa 832958SKNDIN7235098437AAJXB"];
  };

  isoImage.makeUsbBootable = true;
  isoImage.makeEfiBootable = true;
  isoImage.includeSystemBuildDependencies = true; # offline install
  isoImage.storeContents = with pkgs; [
    git
    gnupg
    unzip
    zip
    htop
    vim
    alacritty
    wget
    brave
    git-crypt
    firejail
    dnsutils
    screen
    jq
    pinentry
    srm
    gparted
  ];
  system.stateVersion = "23.05"; # LEAVE AS-IS (unless fresh install)
  system.copySystemConfiguration = true;
  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # Flakes settings
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;
      extra-experimental-features = ["ca-derivations"];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
    };
  };
}
# big issues right now
# look here when you have
# https://github.com/nix-community/nixos-generators
# here are the error messages from show-trace:
# trace: warning: The option `services.openssh.permitRootLogin' defined in `/nix/store/a261zk4kxqiif2wqpg0whr09ajnbvg0y-nixos/nixos/nixos/modules/profiles/installation-device.nix' has been renamed to `services.openssh.settings.PermitRootLogin'.
# trace: warning: The boot.loader.grub.version option does not have any effect anymore, please remove it from your configuration.
# error:
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:816:24:
#           815|     let f = attrPath:
#           816|       zipAttrsWith (n: values:
#              |                        ^
#           817|         let here = attrPath ++ [n]; in
#        … while calling 'g'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:599:19:
#           598|           g =
#           599|             name: value:
#              |                   ^
#           600|             if isAttrs value && cond value
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:602:20:
#           601|               then recurse (path ++ [name]) value
#           602|               else f (path ++ [name]) value;
#              |                    ^
#           603|         in mapAttrs g;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:242:72:
#           241|           # For definitions that have an associated option
#           242|           declaredConfig = mapAttrsRecursiveCond (v: ! isOption v) (_: v: v.value) options;
#              |                                                                        ^
#           243|
#        … while evaluating the option `system.build.toplevel':
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:822:28:
#           821|         # Process mkMerge and mkIf properties.
#           822|         defs' = concatMap (m:
#              |                            ^
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#        … while evaluating definitions from `/nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/top-level.nix':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:823:137:
#           822|         defs' = concatMap (m:
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#              |                                                                                                                                         ^
#           824|         ) defs;
#        … while calling 'dischargeProperties'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:894:25:
#           893|   */
#           894|   dischargeProperties = def:
#              |                         ^
#           895|     if def._type or "" == "merge" then
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/top-level.nix:71:12:
#            70|   # Replace runtime dependencies
#            71|   system = foldr ({ oldDependency, newDependency }: drv:
#              |            ^
#            72|       pkgs.replaceDependency { inherit oldDependency newDependency drv; }
#        … while calling 'foldr'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:53:20:
#            52|   */
#            53|   foldr = op: nul: list:
#              |                    ^
#            54|     let
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:60:8:
#            59|         else op (elemAt list n) (fold' (n + 1));
#            60|     in fold' 0;
#              |        ^
#            61|
#        … while calling 'fold''
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:56:15:
#            55|       len = length list;
#            56|       fold' = n:
#              |               ^
#            57|         if n == len
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/top-level.nix:68:10:
#            67|     then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
#            68|     else showWarnings config.warnings baseSystem;
#              |          ^
#            69|
#        … while calling 'showWarnings'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/trivial.nix:414:28:
#           413|
#           414|   showWarnings = warnings: res: lib.foldr (w: x: warn w x) res warnings;
#              |                            ^
#           415|
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/trivial.nix:414:33:
#           413|
#           414|   showWarnings = warnings: res: lib.foldr (w: x: warn w x) res warnings;
#              |                                 ^
#           415|
#        … while calling 'foldr'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:53:20:
#            52|   */
#            53|   foldr = op: nul: list:
#              |                    ^
#            54|     let
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:60:8:
#            59|         else op (elemAt list n) (fold' (n + 1));
#            60|     in fold' 0;
#              |        ^
#            61|
#        … while calling 'fold''
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:56:15:
#            55|       len = length list;
#            56|       fold' = n:
#              |               ^
#            57|         if n == len
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:59:14:
#            58|         then nul
#            59|         else op (elemAt list n) (fold' (n + 1));
#              |              ^
#            60|     in fold' 0;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/trivial.nix:414:47:
#           413|
#           414|   showWarnings = warnings: res: lib.foldr (w: x: warn w x) res warnings;
#              |                                               ^
#           415|
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:59:34:
#            58|         then nul
#            59|         else op (elemAt list n) (fold' (n + 1));
#              |                                  ^
#            60|     in fold' 0;
#        … while calling 'fold''
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:56:15:
#            55|       len = length list;
#            56|       fold' = n:
#              |               ^
#            57|         if n == len
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:59:14:
#            58|         then nul
#            59|         else op (elemAt list n) (fold' (n + 1));
#              |              ^
#            60|     in fold' 0;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/trivial.nix:414:47:
#           413|
#           414|   showWarnings = warnings: res: lib.foldr (w: x: warn w x) res warnings;
#              |                                               ^
#           415|
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:59:34:
#            58|         then nul
#            59|         else op (elemAt list n) (fold' (n + 1));
#              |                                  ^
#            60|     in fold' 0;
#        … while calling 'fold''
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:56:15:
#            55|       len = length list;
#            56|       fold' = n:
#              |               ^
#            57|         if n == len
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/top-level.nix:48:16:
#            47|   # makes it bootable. See `activatable-system.nix`.
#            48|   baseSystem = pkgs.stdenvNoCC.mkDerivation ({
#              |                ^
#            49|     name = "nixos-system-${config.system.name}-${config.system.nixos.label}";
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/pkgs/stdenv/generic/make-derivation.nix:548:3:
#           547| in
#           548|   fnOrAttrs:
#              |   ^
#           549|     if builtins.isFunction fnOrAttrs
#        … while calling 'g'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:599:19:
#           598|           g =
#           599|             name: value:
#              |                   ^
#           600|             if isAttrs value && cond value
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:602:20:
#           601|               then recurse (path ++ [name]) value
#           602|               else f (path ++ [name]) value;
#              |                    ^
#           603|         in mapAttrs g;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:242:72:
#           241|           # For definitions that have an associated option
#           242|           declaredConfig = mapAttrsRecursiveCond (v: ! isOption v) (_: v: v.value) options;
#              |                                                                        ^
#           243|
#        … while evaluating the option `system.systemBuilderArgs':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:844:59:
#           843|       if isDefined then
#           844|         if all (def: type.check def.value) defsFinal then type.merge loc defsFinal
#              |                                                           ^
#           845|         else let allInvalid = filter (def: ! type.check def.value) defsFinal;
#        … while calling 'merge'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:540:20:
#           539|       check = isAttrs;
#           540|       merge = loc: defs:
#              |                    ^
#           541|         mapAttrs (n: v: v.value) (filterAttrs (n: v: v ? value) (zipAttrsWith (name: defs:
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:541:35:
#           540|       merge = loc: defs:
#           541|         mapAttrs (n: v: v.value) (filterAttrs (n: v: v ? value) (zipAttrsWith (name: defs:
#              |                                   ^
#           542|             (mergeDefinitions (loc ++ [name]) elemType defs).optionalValue
#        … while calling 'filterAttrs'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:309:5:
#           308|     # The attribute set to filter
#           309|     set:
#              |     ^
#           310|     listToAttrs (concatMap (name: let v = set.${name}; in if pred name v then [(nameValuePair name v)] else []) (attrNames set));
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:310:29:
#           309|     set:
#           310|     listToAttrs (concatMap (name: let v = set.${name}; in if pred name v then [(nameValuePair name v)] else []) (attrNames set));
#              |                             ^
#           311|
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:310:62:
#           309|     set:
#           310|     listToAttrs (concatMap (name: let v = set.${name}; in if pred name v then [(nameValuePair name v)] else []) (attrNames set));
#              |                                                              ^
#           311|
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:541:51:
#           540|       merge = loc: defs:
#           541|         mapAttrs (n: v: v.value) (filterAttrs (n: v: v ? value) (zipAttrsWith (name: defs:
#              |                                                   ^
#           542|             (mergeDefinitions (loc ++ [name]) elemType defs).optionalValue
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:541:86:
#           540|       merge = loc: defs:
#           541|         mapAttrs (n: v: v.value) (filterAttrs (n: v: v ? value) (zipAttrsWith (name: defs:
#              |                                                                                      ^
#           542|             (mergeDefinitions (loc ++ [name]) elemType defs).optionalValue
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:822:28:
#           821|         # Process mkMerge and mkIf properties.
#           822|         defs' = concatMap (m:
#              |                            ^
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#        … while evaluating definitions from `/nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/activatable-system.nix':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:823:137:
#           822|         defs' = concatMap (m:
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#              |                                                                                                                                         ^
#           824|         ) defs;
#        … while calling 'dischargeProperties'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:894:25:
#           893|   */
#           894|   dischargeProperties = def:
#              |                         ^
#           895|     if def._type or "" == "merge" then
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/activation-script.nix:137:18:
#           136|       apply = set: set // {
#           137|         script = systemActivationScript set false;
#              |                  ^
#           138|       };
#        … while calling 'systemActivationScript'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/activation-script.nix:20:33:
#            19|
#            20|   systemActivationScript = set: onlyDry: let
#              |                                 ^
#            21|     set' = mapAttrs (_: v: if isString v then (noDepEntry v) // { supportsDryActivation = false; } else v) set;
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/activation/activation-script.nix:49:9:
#            48|
#            49|       ${textClosureMap id (withDrySnippets) (attrNames withDrySnippets)}
#              |         ^
#            50|
#        … while calling 'textClosureMap'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/strings-with-deps.nix:75:35:
#            74|
#            75|   textClosureMap = f: predefined: names:
#              |                                   ^
#            76|     concatStringsSep "\n" (map f (textClosureList predefined names));
#        … while calling 'id'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/trivial.nix:14:5:
#            13|     # The value to return
#            14|     x: x;
#              |     ^
#            15|
#        … while calling 'g'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:599:19:
#           598|           g =
#           599|             name: value:
#              |                   ^
#           600|             if isAttrs value && cond value
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:602:20:
#           601|               then recurse (path ++ [name]) value
#           602|               else f (path ++ [name]) value;
#              |                    ^
#           603|         in mapAttrs g;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:242:72:
#           241|           # For definitions that have an associated option
#           242|           declaredConfig = mapAttrsRecursiveCond (v: ! isOption v) (_: v: v.value) options;
#              |                                                                        ^
#           243|
#        … while evaluating the option `system.activationScripts.etc.text':
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:822:28:
#           821|         # Process mkMerge and mkIf properties.
#           822|         defs' = concatMap (m:
#              |                            ^
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#        … while evaluating definitions from `/nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/etc/etc-activation.nix':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:823:137:
#           822|         defs' = concatMap (m:
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#              |                                                                                                                                         ^
#           824|         ) defs;
#        … while calling 'dischargeProperties'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:894:25:
#           893|   */
#           894|   dischargeProperties = def:
#              |                         ^
#           895|     if def._type or "" == "merge" then
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:816:24:
#           815|     let f = attrPath:
#           816|       zipAttrsWith (n: values:
#              |                        ^
#           817|         let here = attrPath ++ [n]; in
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:565:29:
#           564|       merge = loc: defs:
#           565|         zipAttrsWith (name: defs:
#              |                             ^
#           566|           let merged = mergeDefinitions (loc ++ [name]) elemType defs;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:822:28:
#           821|         # Process mkMerge and mkIf properties.
#           822|         defs' = concatMap (m:
#              |                            ^
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#        … while evaluating definitions from `/nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/etc/etc.nix':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:823:137:
#           822|         defs' = concatMap (m:
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#              |                                                                                                                                         ^
#           824|         ) defs;
#        … while calling 'dischargeProperties'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:894:25:
#           893|   */
#           894|   dischargeProperties = def:
#              |                         ^
#           895|     if def._type or "" == "merge" then
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:88:39:
#            87|         then value
#            88|         else { ${elemAt attrPath n} = atDepth (n + 1); };
#              |                                       ^
#            89|     in atDepth 0;
#        … while calling 'atDepth'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:85:17:
#            84|       len = length attrPath;
#            85|       atDepth = n:
#              |                 ^
#            86|         if n == len
#        … while evaluating derivation 'etc'
#          whose name attribute is located at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/pkgs/stdenv/generic/make-derivation.nix:300:7
#        … while evaluating attribute 'buildCommand' of derivation 'etc'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/pkgs/build-support/trivial-builders/default.nix:87:14:
#            86|       enableParallelBuilding = true;
#            87|       inherit buildCommand name;
#              |              ^
#            88|       passAsFile = [ "buildCommand" ]
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/etc/etc.nix:54:7:
#            53|     mkdir -p "$out/etc"
#            54|     ${concatMapStringsSep "\n" (etcEntry: escapeShellArgs [
#              |       ^
#            55|       "makeEtcEntry"
#        … while calling 'concatMapStringsSep'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/strings.nix:117:5:
#           116|     # List of input strings
#           117|     list: concatStringsSep sep (map f list);
#              |     ^
#           118|
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/etc/etc.nix:54:33:
#            53|     mkdir -p "$out/etc"
#            54|     ${concatMapStringsSep "\n" (etcEntry: escapeShellArgs [
#              |                                 ^
#            55|       "makeEtcEntry"
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/etc/etc.nix:54:43:
#            53|     mkdir -p "$out/etc"
#            54|     ${concatMapStringsSep "\n" (etcEntry: escapeShellArgs [
#              |                                           ^
#            55|       "makeEtcEntry"
#        … while calling 'concatMapStringsSep'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/strings.nix:117:5:
#           116|     # List of input strings
#           117|     list: concatStringsSep sep (map f list);
#              |     ^
#           118|
#        … while calling 'escapeShellArg'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/strings.nix:429:20:
#           428|   */
#           429|   escapeShellArg = arg: "'${replaceStrings ["'"] ["'\\''"] (toString arg)}'";
#              |                    ^
#           430|
#        … while calling 'g'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:599:19:
#           598|           g =
#           599|             name: value:
#              |                   ^
#           600|             if isAttrs value && cond value
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:602:20:
#           601|               then recurse (path ++ [name]) value
#           602|               else f (path ++ [name]) value;
#              |                    ^
#           603|         in mapAttrs g;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:242:72:
#           241|           # For definitions that have an associated option
#           242|           declaredConfig = mapAttrsRecursiveCond (v: ! isOption v) (_: v: v.value) options;
#              |                                                                        ^
#           243|
#        … while evaluating the option `environment.etc."nix/registry.json".source':
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:822:28:
#           821|         # Process mkMerge and mkIf properties.
#           822|         defs' = concatMap (m:
#              |                            ^
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#        … while evaluating definitions from `/nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/system/etc/etc.nix':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:823:137:
#           822|         defs' = concatMap (m:
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#              |                                                                                                                                         ^
#           824|         ) defs;
#        … while calling 'dischargeProperties'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:894:25:
#           893|   */
#           894|   dischargeProperties = def:
#              |                         ^
#           895|     if def._type or "" == "merge" then
#        … while calling 'g'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:599:19:
#           598|           g =
#           599|             name: value:
#              |                   ^
#           600|             if isAttrs value && cond value
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/attrsets.nix:602:20:
#           601|               then recurse (path ++ [name]) value
#           602|               else f (path ++ [name]) value;
#              |                    ^
#           603|         in mapAttrs g;
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:242:72:
#           241|           # For definitions that have an associated option
#           242|           declaredConfig = mapAttrsRecursiveCond (v: ! isOption v) (_: v: v.value) options;
#              |                                                                        ^
#           243|
#        … while evaluating the option `environment.etc."nix/registry.json".text':
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:822:28:
#           821|         # Process mkMerge and mkIf properties.
#           822|         defs' = concatMap (m:
#              |                            ^
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#        … while evaluating definitions from `/nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/nixos/modules/config/nix-flakes.nix':
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:823:137:
#           822|         defs' = concatMap (m:
#           823|           map (value: { inherit (m) file; inherit value; }) (builtins.addErrorContext "while evaluating definitions from `${m.file}':" (dischargeProperties m.value))
#              |                                                                                                                                         ^
#           824|         ) defs;
#        … while calling 'dischargeProperties'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:894:25:
#           893|   */
#           894|   dischargeProperties = def:
#              |                         ^
#           895|     if def._type or "" == "merge" then
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:541:22:
#           540|       merge = loc: defs:
#           541|         mapAttrs (n: v: v.value) (filterAttrs (n: v: v ? value) (zipAttrsWith (name: defs:
#              |                      ^
#           542|             (mergeDefinitions (loc ++ [name]) elemType defs).optionalValue
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/modules.nix:844:59:
#           843|       if isDefined then
#           844|         if all (def: type.check def.value) defsFinal then type.merge loc defsFinal
#              |                                                           ^
#           845|         else let allInvalid = filter (def: ! type.check def.value) defsFinal;
#        … while calling 'merge'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:859:20:
#           858|       check = x: t1.check x || t2.check x;
#           859|       merge = loc: defs:
#              |                    ^
#           860|         let
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:864:21:
#           863|           if   all (x: t1.check x) defList
#           864|                then t1.merge loc defs
#              |                     ^
#           865|           else if all (x: t2.check x) defList
#        … while calling 'merge'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:859:20:
#           858|       check = x: t1.check x || t2.check x;
#           859|       merge = loc: defs:
#              |                    ^
#           860|         let
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/types.nix:866:21:
#           865|           else if all (x: t2.check x) defList
#           866|                then t2.merge loc defs
#              |                     ^
#           867|           else mergeOneOption loc defs;
#        … while calling 'mergeEqualOption'
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/options.nix:228:27:
#           227|   /* "Merge" option definitions by checking that they all have the same value. */
#           228|   mergeEqualOption = loc: defs:
#              |                           ^
#           229|     if defs == [] then abort "This case should never happen."
#        … from call site
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/options.nix:234:11:
#           233|     else if length defs == 1 then (head defs).value
#           234|     else (foldl' (first: def:
#              |           ^
#           235|       if def.value != first.value then
#        … while calling 'foldl''
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/lists.nix:139:5:
#           138|     # The list to fold
#           139|     list:
#              |     ^
#           140|
#        … while calling anonymous lambda
#          at /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source/lib/options.nix:234:26:
#           233|     else if length defs == 1 then (head defs).value
#           234|     else (foldl' (first: def:
#              |                          ^
#           235|       if def.value != first.value then
#        error: The option `nix.registry.nixpkgs.to.path' has conflicting definition values:
#        - In `/nix/var/nix/profiles/per-user/root/channels/nixos/nixos/modules/installer/cd-dvd/channel.nix':
#            {
#              _isLibCleanSourceWith = true;
#              filter = <function>;
#              name = "source";
#              origSrc = /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source;
#            ...
#        - In `/nix/store/a261zk4kxqiif2wqpg0whr09ajnbvg0y-nixos/nixos/nixos/modules/installer/cd-dvd/channel.nix':
#            {
#              _isLibCleanSourceWith = true;
#              filter = <function>;
#              name = "source";
#              origSrc = /nix/store/r88zkfh22shcgj0c4zh9jj2q5r1z9wjn-source;
#            ...
#        Use `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions.

