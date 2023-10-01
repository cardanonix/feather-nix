{pkgs ? import <nixpkgs> {}}:
with pkgs;
  mkShell {
    buildInputs = [
      nixpkgs-fmt
    ];

    shellHook = ''
      export NIX_SHELL_NAME="nix-config shell"
      echo "Welcome to my nix-config devShell!"
      echo
      echo opening VSCodium for this project....
      codium .
      echo .
      echo ..
      echo welcome to the my devshell

    '';
  }
