{
  config,
  lib,
  pkgs,
  ...
}: let
  labyrinth-sddm = pkgs.stdenv.mkDerivation {
    name = "labyrinth-sddm";
    src = ./.config/sddm;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/labyrinth-sddm
      cp -r * $out/share/sddm/themes/labyrinth-sddm/
    '';
  };
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  security.pam.services.swaylock = {};
  time.timeZone = "Asia/Kolkata";

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # List packages installed in system profile.
  environment.systemPackages = [
    pkgs.unzip
    pkgs.vim
    pkgs.wget
    labyrinth-sddm
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
    hostName = "labyrinth";
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
    nix-ld.enable = true;
    zsh.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  services = {
    cloudflare-warp.enable = true;
    printing.enable = true; # Enable CUPS to print documents.
    # openssh.enable = true; # Enable the OpenSSH daemon.

    displayManager.sddm = {
      enable = true;
      theme = "labyrinth-sddm";
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
      enable = true; # Enable sound.
      pulse.enable = true;
    };

    xserver = {
      enable = true; # Enable the X11 windowing system.
      xkb.layout = "us"; # Configure keymap in X11
      # xkb.options = "eurosign:e,caps:escape";

      displayManager.setupCommands = ''
        ${pkgs.redshift}/bin/redshift -m randr -P -O 4000 &
      '';
    };
  };

  # Define a user account.
  users.users.tangerine = {
    description = "Tangerine Arc";
    extraGroups = ["wheel"];
    home = "/home/tangerine";
    isNormalUser = true;
    shell = pkgs.zsh;

    # packages = with pkgs; [
    #  vim
    #];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
