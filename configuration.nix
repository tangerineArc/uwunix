{
  config,
  lib,
  pkgs,
  user,
  host,
  stateVersion,
  ...
}: let
  labyrinth-sddm = pkgs.stdenv.mkDerivation {
    name = "material-you-sddm";
    src = ./config/sddm;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/material-you-sddm
      cp -r * $out/share/sddm/themes/material-you-sddm/
    '';
  };
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  location.provider = "geoclue2";
  time.timeZone = "Asia/Kolkata";
  system.stateVersion = stateVersion; # Never change this

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # List packages installed in system profile.
  environment.systemPackages = [
    labyrinth-sddm
    pkgs.git
    pkgs.unzip
    pkgs.vim
    pkgs.wget
  ];

  fonts = {
    fontconfig.enable = true;

    packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };

  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;
  };

  networking = {
    hostName = host;
    networkmanager.enable = true; # Configure network connections with nmcli or nmtui.

    # Open ports in the firewall.
    # firewall = {
    #   allowedTCPPorts = [ ... ];
    #   allowedUDPPorts = [ ... ];
    #   # Or disable the firewall altogether.
    #   enable = false;
    # };

    # Configure network proxy if necessary
    # proxy = {
    #   default = "http://user:password@proxy:port/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };
  };

  programs = {
    niri.enable = true;
    zsh.enable = true;

    nix-ld = {
      enable = true;

      libraries = [
        pkgs.stdenv.cc.cc
        pkgs.zlib
      ];
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  security = {
    polkit.enable = true;

    pam.services = {
      hyprlock = {};
      login.fprintAuth = true;
      polkit-1.fprintAuth = true;
      sudo.fprintAuth = true;

      sddm = {
        fprintAuth = false;

        text = ''
          account include login
          auth optional pam_unix.so likeauth nullok
          auth optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
          auth sufficient pam_unix.so likeauth nullok try_first_pass
          auth required pam_deny.so
          password include login
          session include login
        '';
      };
    };
  };

  services = {
    cloudflare-warp.enable = true;
    fprintd.enable = true;
    gvfs.enable = true;
    # openssh.enable = true; # Enable the OpenSSH daemon.
    power-profiles-daemon.enable = true;
    printing.enable = true; # Enable CUPS to print documents.
    udisks2.enable = true;
    upower.enable = true;

    displayManager.sddm = {
      enable = true;
      theme = "material-you-sddm";

      extraPackages = [
        pkgs.qt6.qt5compat # dependency
      ];
    };

    geoclue2.appConfig.zen = {
      isAllowed = true;
      isSystem = true;
    };

    kmscon = {
      enable = true;

      config = {
        font-name = "JetBrainsMono Nerd Font";
        hwaccel = true;

        palette = "custom";
        palette-background = "29,32,33";
        palette-foreground = "235,219,178";
        palette-black = "29,32,33";
        palette-red = "204,36,29";
        palette-green = "152,151,26";
        palette-yellow = "215,153,33";
        palette-blue = "69,133,136";
        palette-magenta = "177,98,134";
        palette-cyan = "104,157,106";
        palette-light-grey = "168,153,132";
        palette-dark-grey = "146,131,116";
        palette-light-red = "251,73,52";
        palette-light-green = "184,187,38";
        palette-light-yellow = "250,189,47";
        palette-light-blue = "131,165,152";
        palette-light-magenta = "211,134,155";
        palette-light-cyan = "142,192,124";
        palette-white = "235,219,178";
      };
    };

    # Enable touchpad support.
    libinput = {
      enable = true;

      touchpad = {
        accelSpeed = "0.8";
        tapping = true;
      };
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    xserver = {
      enable = true; # Enable the X11 windowing system.
      xkb.layout = "us"; # Configure keymap in X11
      # xkb.options = "eurosign:e,caps:escape";
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  users.users.${user} = {
    description = "Maester";
    extraGroups = ["wheel" "input"];
    home = "/home/${user}";
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}
