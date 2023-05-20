let
  more = {
    programs = {
      bat.enable = true;

      # broot = {
      #   enable = true;
      #   enableFishIntegration = true;
      #   # enableZshIntegration = true;
      # };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultCommand = "ripgrep/bin/rg --files"; # FZF_DEFAULT_COMMAND
        defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
        fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
      };

      # zsh settings
      zsh = {
        # inherit shellAliases;
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        history.extended = true;

        # Called whenever zsh is initialized
        initExtra = ''
          export TERM="xterm-256color"
          bindkey -e

          # Nix setup (environment variables, etc.)
          # if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
          #   . ~/.nix-profile/etc/profile.d/nix.sh
          # fi

          # Load environment variables from a file; this approach allows me to not
          # commit secrets like API keys to Git
          # if [ -e ~/.env ]; then
          #   . ~/.env
          # fi

          # Start up Starship shell
          eval "$(starship init zsh)"

          # Autocomplete for various utilities
          # source <(helm completion zsh)
          # source <(kubectl completion zsh)
          # source <(linkerd completion zsh)
          # source <(doctl completion zsh)
          # source <(minikube completion zsh)
          # source <(gh completion --shell zsh)
          # rustup completions zsh > ~/.zfunc/_rustup
          # source <(cue completion zsh)
          # source <(npm completion zsh)
          # source <(humioctl completion zsh)
          # source <(fluxctl completion zsh)

          # direnv setup
          eval "$(direnv hook zsh)"

          # Start up Docker daemon if not running
          # if [ $(docker-machine status default) != "Running" ]; then
          #   docker-machine start default
          # fi

          # Docker env
          # eval "$(docker-machine env default)"

          # Load asdf
          # . $HOME/.asdf/asdf.sh

          # direnv hook
          eval "$(direnv hook zsh)"
        '';
      };

      gpg.enable = true;

      htop = {
        enable = true;
        settings = {
          sort_direction = true;
          sort_key = "PERCENT_CPU";
        };
      };

      jq.enable = true;

      obs-studio = {
        enable = false;
        plugins = [ ];
      };

      ssh.enable = true;

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [ ];
      };
    };
  };
in
[
  ./alacritty
  # ./browsers/firefox.nix
  ./browsers/brave.nix
  # ./cardano
  # ./git
  ./fish
  ./neofetch
  # ./guild-operators
  # ./tmux
  # ./neovim-ide
  ./vscode
  # ./yubikey
  more
]