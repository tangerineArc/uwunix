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
      pkgs.awww
      pkgs.bluetui
      pkgs.brightnessctl
      pkgs.fastfetch
      pkgs.fd # dependency
      pkgs.fuzzel
      pkgs.fzf # dependency
      pkgs.gcc
      pkgs.ghostty
      pkgs.gnumake
      pkgs.imv
      pkgs.lsd
      pkgs.neovim
      pkgs.nodejs
      pkgs.pkg-config # dependency
      pkgs.ripgrep # dependency
      pkgs.rustup
      pkgs.smile
      pkgs.tree-sitter # dependency
      pkgs.wl-clipboard # dependency
      pkgs.zoxide # dependency
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };

  programs = {
    bottom.enable = true;
    home-manager.enable = true;

    chromium = {
      enable = true;

      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--load-extension=${config.home.homeDirectory}/.config/chromium-theme"
      ];

      extensions = [
        # Base16 Everything
        {id = "jmofeafhkeohbpbedgbnkdlfaomjbnkf";}
        # uBlock Origin Lite
        {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";}
      ];
    };

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
        lua.symbol = " ";
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

  services = {
    cliphist.enable = true;

    gammastep = {
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

    mako = {
      enable = true;

      settings = {
        default-timeout = 5000; # 5000ms = 5s
        background-color = "#1d2021";
        border-color = "#665c54";
        border-radius = 10;
        font = "JetBrainsMono Nerd Font 11";
        height = 500;
        padding = "15,20";
        text-color = "#fbf1c7";
        width = 400;
      };
    };

    swayidle = {
      enable = true;
      events.before-sleep = "${pkgs.swaylock}/bin/swaylock -f";

      timeouts = [
        {
          command = "${pkgs.swaylock}/bin/swaylock -f";
          timeout = 300; # 300s = 5 minutes
        }
        {
          command = "${pkgs.systemd}/bin/systemctl suspend";
          timeout = 600; # 600s = 10 minutes
        }
      ];
    };
  };

  xdg.configFile = {
    # Chromium theme config
    "chromium-theme/manifest.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/chromium-theme/manifest.json";

    # Fastfetch config
    "fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fastfetch/config.jsonc";

    # Ghostty config
    "ghostty/config.ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/config.ghostty";

    # Neovim (kickstart.nvim) config
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim";

    # Niri config
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/niri.kdl";
  };
}
