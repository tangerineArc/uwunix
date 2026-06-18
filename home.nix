{
  config,
  pkgs,
  lib,
  inputs,
  user,
  gitName,
  gitEmail,
  stateVersion,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.minos.homeManagerModules.default
  ];

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
    homeDirectory = "/home/${user}";
    stateVersion = stateVersion;
    username = user;

    activation = {
      installRust = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.rustup}/bin/rustup default stable
        ${pkgs.rustup}/bin/rustup component add rust-analyzer
      '';

      setupDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "$HOME/Devel/"
        mkdir -p "$HOME/Documents/"
        mkdir -p "$HOME/Downloads/"
        mkdir -p "$HOME/Pictures/Screenshots/"
        mkdir -p "$HOME/Pictures/Wallpapers/"
      '';

      setupDefaultWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f "$HOME/.cache/current-wallpaper" ]; then
          ln -sf "$HOME/.dotfiles/assets/nixos-dark.png" "$HOME/.cache/current-wallpaper"
        fi
      '';
    };

    packages = [
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

      pkgs.adwaita-icon-theme
      pkgs.adw-gtk3 # dependency
      pkgs.ani-cli
      pkgs.awww
      pkgs.bluetui
      pkgs.brightnessctl
      pkgs.fastfetch
      pkgs.fd # dependency
      pkgs.ffmpeg
      pkgs.fuzzel
      pkgs.gcc
      pkgs.ghostty
      pkgs.glib # dependency
      pkgs.glibc.dev # dependency
      pkgs.gnumake
      pkgs.imv
      pkgs.jq
      pkgs.lsd
      pkgs.matugen
      pkgs.nautilus
      pkgs.neovim
      pkgs.nodejs
      pkgs.pkg-config # dependency
      pkgs.playerctl
      pkgs.polkit_gnome
      pkgs.proton-vpn
      pkgs.python3
      pkgs.qt6.qtdeclarative # dependency
      pkgs.ripgrep # dependency
      pkgs.rustup
      pkgs.smile
      pkgs.snapshot
      pkgs.tree-sitter # dependency
      pkgs.wl-clipboard
      pkgs.wl-gammarelay-rs
      pkgs.zed-editor
      pkgs.zoxide # dependency

      (pkgs.writeShellScriptBin
        "fresco"
        ''
          IMAGE=$(readlink -f "$1")

          if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
            echo "Usage: fresco <path-to-wallpaper>"
            exit 1
          fi

          ln -sf "$IMAGE" ~/.cache/current-wallpaper

          awww img "$IMAGE" --transition-type random
          matugen image "$IMAGE" -m dark -t scheme-tonal-spot --source-color-index 0
        '')
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    sessionVariables = {
      C_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
      CPLUS_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    home-manager.enable = true;
    hyprlock.enable = true;

    btop = {
      enable = true;
      settings = {
        color_theme = "matugen";
        theme_background = false;
      };
    };

    chromium = {
      enable = true;
      package = pkgs.chromium.override {enableWideVine = true;};

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

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
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
          email = gitEmail;
          name = gitName;
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
        deno.symbol = " ";
        git_branch.symbol = " ";
        lua.symbol = " ";
        nix_shell.symbol = " ";
        package.symbol = "󰏗 ";
        python.symbol = "󰌠 ";
        rust.symbol = " ";

        character = {
          success_symbol = "[ ](bold green)";
          error_symbol = "[ ](bold red)";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          modified = "[+](bold red)";
        };

        time = {
          disabled = false;
          format = "[✦](bold cyan) at [$time]($style) ";
          style = "bold yellow";
        };
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
    minos.enable = true;
    playerctld.enable = true;

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
      events.before-sleep = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";

      timeouts = [
        {
          command = "${pkgs.hyprlock}/bin/hyprlock";
          timeout = 540; # 540s = 9 minutes
        }
        {
          command = "${pkgs.systemd}/bin/systemctl suspend";
          timeout = 600; # 600s = 10 minutes
        }
      ];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  xdg = {
    configFile = {
      # Btop theme config
      "btop/themes/matugen.theme".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.cache/matugen/btop.theme";

      # Chromium theme config
      "chromium-theme/manifest.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.cache/matugen/chromium-theme.json";

      # Fastfetch config
      "fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fastfetch/config.jsonc";

      # Fuzzel config
      "fuzzel/fuzzel.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fuzzel.ini";

      # Ghostty config
      "ghostty/config.ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/config.ghostty";

      # Gtk-3.0 css
      "gtk-3.0/gtk.css".text = ''
        @import 'colors.css';
      '';

      # Gtk-4.0 css
      "gtk-4.0/gtk.css".text = ''
        @import 'colors.css';
      '';

      # Hyprlock config
      "hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/hyprlock";

      # Matugen config
      "matugen".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/matugen";

      # Neovim (kickstart.nvim) config
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim";

      # Niri config
      "niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/niri";

      # Yazi config
      "yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/yazi.toml";

      # Zed config
      "zed".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/zed";
    };

    desktopEntries = {
      crunchyroll = {
        categories = ["Network" "Video" "X-Anime"];
        exec = "chromium --app=https://crunchyroll.com %U";
        icon = "crunchyroll";
        name = "Crunchyroll";
        terminal = false;
      };

      gemini = {
        categories = ["Network" "X-AI"];
        exec = "chromium --app=https://gemini.google.com %U";
        icon = "/home/${user}/.dotfiles/config/icons/google-gemini.svg";
        name = "Google Gemini";
        terminal = false;
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
