{
  inputs = {
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # rust-overlay = {
    #   url = "github:oxalica/rust-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # wezterm = {
    #   url = "github:wez/wezterm?dir=nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.rust-overlay.follows = "rust-overlay";
    # };
  };

  outputs =
    { self, ... }@inputs:
    {
      darwinConfigurations."wil-mac" = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          ./common.nix
          ./wil-mac/configuration.nix

          # inputs.home-manager.darwinModules.home-manager
          # {
          #   home-manager = {
          #     useGlobalPkgs = true;
          #     useUserPackages = true;
          #     users.wil.imports = [ ./modules/home-manager ];
          #   };
          # }
        ];
        specialArgs = {
          inherit self inputs;
          system = "aarch64-darwin";
          hostname = "wil-mac";
        };
      };

      nixosConfigurations."mbk" = inputs.nixpkgs-nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common.nix
          ./mbk/hardware-configuration.nix
          ./mbk/configuration.nix
          ./modules/plex.nix
        ];
        specialArgs = {
          inherit self inputs;
          system = "x86_64-linux";
          hostname = "mbk";
        };
      };
    };
}
