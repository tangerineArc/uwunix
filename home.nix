{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  home = {
    homeDirectory = "/home/tangerine";
    # This value determines the Home Manager release that your
    # configuration is compatible with. Match it with your system.
    stateVersion = "25.11";
    username = "tangerine";

    activation = {
      installRust = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.rustup}/bin/rustup default stable
        ${pkgs.rustup}/bin/rustup component add rust-analyzer
      '';
    };

    packages = [
      pkgs.bluetui
      pkgs.brightnessctl
      pkgs.fd # dependency
      pkgs.fzf # dependency
      pkgs.gcc
      pkgs.ghostty
      pkgs.gnumake
      pkgs.lsd
      pkgs.neovim
      pkgs.nodejs
      pkgs.pkg-config # dependency
      pkgs.ripgrep # dependency
      pkgs.rustup
      pkgs.swaybg
      pkgs.tree-sitter # dependency
      pkgs.zoxide # dependency
    ];
  };

  programs = {
    bottom.enable = true;
    chromium.enable = true;
    home-manager.enable = true;

    git = {
      enable = true;

      settings = {
        init.defaultBranch = "main";

        user = {
          email = "swagatam.pati.2104@gmail.com";
          name = "Swagatam Pati";
        };
      };
    };

    mpv = {
      enable = true;

      config = {
        gpu-context = "wayland";
        hwdec = "auto-safe";
        profile = "gpu-hq";
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        format = "$all$line_break$time$character";
        git_branch.symbol = " ";
        package.symbol = "󰏗 ";
        rust.symbol = " ";

        character = {
          success_symbol = "[ ](bold green)";
          error_symbol = "[ ](bold red)";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          modified = "[+](bold red)";
        };

        nix_shell = {
          symbol = "❄ ";
          format = "via [$symbol$state($name)]($style) ";
        };

        time = {
          disabled = false;
          format = "[✦](bold cyan) at [$time]($style) ";
          style = "bold yellow";
        };
      };
    };

    swaylock = {
      enable = true;

      settings = {
        font = "JetBrainsMono Nerd Font";
        indicator-idle-visible = true;
      };
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";

      settings = {
        open.prepend_rules = [
          {
            mime = "video/*";
            use = "mpv_player";
          }
        ];

        opener.mpv_player = [
          {
            desc = "Play with mpv";
            orphan = true;
            run = ''mpv "$@"'';
          }
        ];
      };
    };

    zsh = {
      autosuggestion.enable = true;
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        # Fix weird gap on top of prompt due to starship
        precmd() {
          precmd() {
            echo
          }
        }
        alias clear="precmd() { precmd() { echo } } && clear"

        # Fix Ctrl+Left and Ctrl+Right word jumping
        bindkey "^[[1;5D" backward-word
        bindkey "^[[1;5C" forward-word
      '';
    };
  };

  services.gammastep = {
    enable = true;
    provider = "manual";

    latitude = 0.0;
    longitude = 0.0;

    settings.general = {
      brightness-day = "1.0";
      brightness-night = "1.0";
      fade = 0;
    };

    temperature = {
      day = 4000;
      night = 4000;
    };
  };

  xdg.configFile = {
    # Ghostty config
    "ghostty/config.ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/config.ghostty";

    # Neovim (kickstart.nvim) config
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim";

    # Niri config
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/niri.kdl";
  };
}
