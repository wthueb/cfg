{
  inputs = {
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixos-stable";
    };

    i915-sriov = {
      url = "github:strongtz/i915-sriov-dkms?ref=2025.11.10";
      inputs.nixpkgs.follows = "nixos-stable";
    };
  };

  outputs =
    { self, ... }@inputs:
    {
      darwinConfigurations."wil-mac" = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./common.nix
          ./wil-mac/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.wil.imports = [ ./home.nix ];
            };
          }
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "wil-mac";
        };
      };

      darwinConfigurations."osx" = inputs.nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./common.nix
          ./osx/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.wil.imports = [ ./home.nix ];
            };
          }
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "osx";
        };
      };

      nixosConfigurations."mbk" = inputs.nixos-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.wil.imports = [ ./home.nix ];
            };
          }
          ./modules/nixos.nix
          ./mbk/configuration.nix
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "mbk";
        };
      };

      nixosConfigurations."monitor" = inputs.nixos-stable.lib.nixosSystem {
        system = "x86-linux";
        modules = [
          ./common.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.wil.imports = [ ./home.nix ];
            };
          }
          ./modules/nixos.nix
          ./monitor/configuration.nix
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "monitor";
        };
      };

      homeConfigurations = {
        "wil@drake" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixos-stable.legacyPackages.x86_64-linux;
          modules = [
            {
              home.username = "wil";
              home.homeDirectory = "/home/wil";
            }
            ./home.nix
          ];
        };
      };
    };
}
