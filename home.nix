{
  config,
  pkgs,
  lib,
  inputs,
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

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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
      inputs.zen-browser.packages."${pkgs.system}".default
      pkgs.awww
      pkgs.bluetui
      pkgs.brightnessctl
      pkgs.btop
      pkgs.fastfetch
      pkgs.fd # dependency
      pkgs.ffmpeg
      pkgs.fuzzel
      pkgs.gcc
      pkgs.ghostty
      pkgs.gnumake
      pkgs.imv
      pkgs.lsd
      pkgs.neovim
      pkgs.nodejs
      pkgs.pkg-config # dependency
      pkgs.python3
      pkgs.qt6.qtdeclarative # dependency
      pkgs.ripgrep # dependency
      pkgs.rustup
      pkgs.smile
      pkgs.snapshot
      pkgs.tree-sitter # dependency
      pkgs.wl-clipboard
      pkgs.zoxide # dependency
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
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

    fzf = {
      enable = true;
      enableZshIntegration = true;
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
    };

    zsh = {
      autosuggestion.enable = true;
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        # Force standard emacs mode bindings
        bindkey -e

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

      shellAliases = {
        glog = "git log --oneline --graph --decorate --all --color=always | less";
        py = "python3";
      };
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
        background-color = "#1d2021ff";
        border-color = "#83a59822";
        border-radius = 10;
        border-size = 6;
        default-timeout = 5000; # 5000ms = 5s
        font = "JetBrainsMono Nerd Font 11";
        height = 500;
        icon-path = "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark:${pkgs.hicolor-icon-theme}/share/icons/hicolor";
        layer = "overlay";
        max-icon-size = 48;
        on-button-right = "dismiss --no-history";
        padding = "15,20";
        text-color = "#ebdbb2ff";
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

  xdg = {
    configFile = {
      # Chromium theme config
      "chromium-theme/manifest.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/chromium-theme/manifest.json";

      # Fastfetch config
      "fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fastfetch/config.jsonc";

      # Fuzzel config
      "fuzzel/fuzzel.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fuzzel.ini";

      # Ghostty config
      "ghostty/config.ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/config.ghostty";

      # Neovim (kickstart.nvim) config
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim";

      # Niri config
      "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/niri.kdl";

      # Yazi config
      "yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/yazi.toml";
    };

    desktopEntries = {
      gemini = {
        categories = ["Network" "X-AI"];
        exec = "chromium --app=https://gemini.google.com %U";
        name = "Google Gemini";
        terminal = false;
        icon = "/home/tangerine/.dotfiles/config/icons/google-gemini.svg";
      };

      whatsapp = {
        categories = ["Network" "Chat" "InstantMessaging"];
        exec = "chromium --app=https://web.whatsapp.com %U";
        icon = "whatsapp";
        name = "WhatsApp Web";
        terminal = false;
      };

      yazi = {
        categories = ["System" "FileTools" "FileManager" "ConsoleOnly"];
        exec = "yazi %u";
        icon = "system-file-manager";
        name = "Yazi";
        terminal = true;
      };

      youtube = {
        categories = ["Network" "Video"];
        exec = "chromium --app=https://www.youtube.com %U";
        icon = "youtube";
        name = "YouTube";
        terminal = false;
      };

      youtube-music = {
        categories = ["Network" "Audio" "Music"];
        exec = "chromium --app=https://music.youtube.com %U";
        icon = "youtube-music";
        name = "YouTube Music";
        terminal = false;
      };

      zen = {
        categories = ["Network" "WebBrowser"];
        exec = "zen %U";
        icon = "zen-browser";
        name = "Zen Browser";
        terminal = false;
      };
    };
  };
}
