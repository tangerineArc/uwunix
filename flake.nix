{
  description = "Labyrinth Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    minos = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:tangerineArc/minos";
    };

    opencode = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:dan-online/opencode-nix";
    };

    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:0xc000022070/zen-browser-flake";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    opencode,
    ...
  } @ inputs: let
    # --- CONFIGURATION VARIABLES ---
    user = "tangerine";
    host = "labyrinth";
    gitName = "Swagatam Pati";
    gitEmail = "swagatam.pati.2104@gmail.com";
    stateVersion = "25.11";
    # --- --- --- --- --- --- --- ---

    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;

      overlays = [opencode.overlays.default];
    };
  in {
    nixosConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {inherit user host stateVersion;};

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };

    homeConfigurations = {
      "${user}@${host}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit inputs user host gitName gitEmail stateVersion;};

        modules = [
          ./home.nix
        ];
      };
    };
  };
}
