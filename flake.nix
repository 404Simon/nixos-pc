{
  description = "flakezz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.pc = nixpkgs.lib.nixosSystem {
        inherit system;

	specialArgs = {
	  inherit pkgs-unstable;
	};
        modules = [
          disko.nixosModules.disko
          
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

	    home-manager.extraSpecialArgs = {
	      inherit pkgs-unstable;
	    };
            home-manager.users.simon = import ./home.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}

