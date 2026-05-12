{
  description = "Labyrinth Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:youwen5/zen-browser-flake";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      "labyrinth" = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };

    homeConfigurations = {
      "tangerine@labyrinth" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit inputs;};

        modules = [
          ./home.nix
        ];
      };
    };
  };
}
