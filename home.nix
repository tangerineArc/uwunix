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
}: let
  antigravity-cli = pkgs.stdenv.mkDerivation rec {
    pname = "antigravity-cli";
    sourceRoot = ".";
    version = "1.1.3";

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp antigravity $out/bin/agy
      chmod +x $out/bin/agy
    '';

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    src = pkgs.fetchurl {
      url = "https://github.com/google-antigravity/antigravity-cli/releases/download/${version}/agy_cli_linux_x64.tar.gz";
      hash = "sha256-enI5pptl08869+dfJ7L/TpzOaWp7mp5cN8aV8cdO7DQ=";
    };
  };
in {
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.noctalia.homeModules.default
    inputs.zen-browser.homeModules.beta
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

      # niri config includes $XDG_CACHE_HOME/noctalia/niri.kdl, but that file is
      # only generated once noctalia itself runs (which niri autostarts). A missing
      # include invalidates the whole niri config, so seed it here to break the cycle.
      seedNoctaliaCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
                NOCTALIA_CACHE="$HOME/.cache/noctalia"
                mkdir -p "$NOCTALIA_CACHE"
                if [ ! -f "$NOCTALIA_CACHE/niri.kdl" ]; then
                  if [ -f "$HOME/.cache/matugen/niri.kdl" ]; then
                    cp "$HOME/.cache/matugen/niri.kdl" "$NOCTALIA_CACHE/niri.kdl"
                  else
                    cat > "$NOCTALIA_CACHE/niri.kdl" <<'NIRI_EOF'
        layout {
            border {
                active-color "#7aa2f722"
                inactive-color "#565f8922"
                urgent-color "#f7768e22"
            }
            insert-hint {
                color "#7aa2f780"
            }
        }
        overview {
            backdrop-color "#1a1b26"
        }
        recent-windows {
            highlight {
                active-color "#394264aa"
            }
        }
        NIRI_EOF
                  fi
                fi
      '';
    };

    packages = [
      antigravity-cli

      pkgs.adwaita-icon-theme
      pkgs.adw-gtk3 # dependency
      pkgs.ani-cli
      pkgs.bluetui
      pkgs.brightnessctl
      pkgs.fastfetch
      pkgs.fd # required by nvim telescope
      pkgs.ffmpeg
      pkgs.gcc
      pkgs.ghostty
      pkgs.thunderbird
      # -- Android development --
      pkgs.android-studio
      pkgs.android-tools
      pkgs.gradle
      pkgs.httptoolkit
      pkgs.kotlin
      pkgs.kotlin-language-server
      pkgs.scrcpy
      # JDK 17 kept available for AGP 7 compatibility via `nix shell nixpkgs#jdk17`
      # (not added to home.packages to avoid man-page collision with JDK 21)
      pkgs.glib # dependency
      pkgs.glibc.dev # dependency
      pkgs.gnumake
      pkgs.imv
      pkgs.jq
      pkgs.lsd
      pkgs.nautilus
      pkgs.neovim
      pkgs.nodejs
      pkgs.pkg-config # dependency
      pkgs.playerctl
      pkgs.proton-vpn
      pkgs.python3
      pkgs.qt6.qtdeclarative # dependency
      pkgs.ripgrep # dependency
      pkgs.smile
      pkgs.snapshot
      pkgs.tree-sitter # dependency
      pkgs.wl-clipboard
      pkgs.zed-editor

      (pkgs.rust-bin.stable.latest.default.override {
        extensions = ["rust-src" "rust-analyzer"];
      })

      # -- Scripts --
      (pkgs.writeShellScriptBin
        "fresco"
        ''
          IMAGE=$(readlink -f "$1")

          if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
            echo "Usage: fresco <path-to-wallpaper>"
            exit 1
          fi

          ln -sf "$IMAGE" ~/.cache/current-wallpaper

          noctalia msg wallpaper-set "$IMAGE"
        '')

      (pkgs.writeShellApplication {
        name = "opencode";
        text = ''
          exec ${pkgs.nodejs}/bin/npx @opencode/cli@latest "$@"
        '';
      })
    ];

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    sessionVariables = {
      ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
      ANDROID_SDK_ROOT = "${config.home.homeDirectory}/Android/Sdk";
      C_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
      CPLUS_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
      EDITOR = "nvim";
      JAVA_HOME = "${pkgs.jdk}/lib/openjdk";
      VISUAL = "nvim";
      # Work around Java AWT / niri Wayland issues
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    sessionPath = [
      "${config.home.homeDirectory}/Android/Sdk/emulator"
      "${config.home.homeDirectory}/Android/Sdk/platform-tools"
      "${config.home.homeDirectory}/Android/Sdk/cmdline-tools/latest/bin"
    ];
  };

  programs = {
    home-manager.enable = true;

    noctalia = {
      enable = true;
      systemd.enable = false;
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "noctalia";
        theme_background = false;
      };
    };

    java = {
      enable = true;
      package = pkgs.jdk; # JDK 21 (use pkgs.jdk17 for AGP 7 compatibility via direnv)
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

    zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
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

  xdg = {
    configFile = {
      # Fastfetch config
      "fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fastfetch/config.jsonc";

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

      # Neovim (kickstart.nvim) config
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim";

      # Niri config
      "niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/niri";

      # Noctalia config (symlinked so edits hot-reload without a rebuild)
      "noctalia".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/noctalia";

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

      teams = {
        categories = ["Network" "Chat"];
        exec = "chromium --app=https://teams.cloud.microsoft %U";
        icon = "teams-for-linux";
        name = "Microsoft Teams";
        terminal = false;
      };

      whatsapp = {
        categories = ["Network" "Chat" "InstantMessaging"];
        exec = "chromium --app=https://web.whatsapp.com %U";
        icon = "whatsapp";
        name = "WhatsApp Web";
        terminal = false;
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
    };
  };
}
