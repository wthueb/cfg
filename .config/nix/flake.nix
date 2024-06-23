{
  description = "wthueb's macbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    {
      darwinConfigurations."wil-mac" = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix

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
          inherit inputs;
        };
      };

      darwinPackages = self.darwinConfigurations."wil-mac".pkgs;
    };
}
