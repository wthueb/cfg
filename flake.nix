{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    i915-sriov = {
      url = "github:strongtz/i915-sriov-dkms?ref=2025.12.10";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:JafarAbdi/wezterm/render_fix?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    btop = {
      url = "github:aristocratos/btop/main";
      flake = false;
    };

    catppuccin-btop = {
      url = "github:catppuccin/btop/main";
      flake = false;
    };

    deploy-rs = {
      #url = "github:serokell/deploy-rs";
      url = "github:szlend/deploy-rs/fix-show-derivation-parsing";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      nixpkgsConf = {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = import ./overlays.nix { inherit inputs; };
        };
      };

      homeConfig = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.wil = import ./home;
          extraSpecialArgs = { inherit inputs; };
        };
      };

      mkDarwinSystem =
        {
          system,
          modules,
          hostname,
        }:
        inputs.nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            nixpkgsConf
            inputs.determinate.darwinModules.default
            ./modules/darwin.nix
            ./common.nix
            inputs.home-manager.darwinModules.home-manager
            homeConfig
          ]
          ++ modules;
          specialArgs = { inherit self inputs hostname; };
        };

      mkNixosSystem =
        {
          system,
          modules,
          hostname,
        }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixpkgsConf
            inputs.determinate.nixosModules.default
            ./modules/nixos.nix
            ./common.nix
            inputs.home-manager.nixosModules.home-manager
            homeConfig
          ]
          ++ modules;
          specialArgs = { inherit self inputs hostname; };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        darwinConfigurations."wil-mac" = mkDarwinSystem {
          system = "aarch64-darwin";
          modules = [ ./hosts/wil-mac ];
          hostname = "wil-mac";
        };

        darwinConfigurations."osx" = mkDarwinSystem {
          system = "x86_64-darwin";
          modules = [ ./hosts/osx ];
          hostname = "osx";
        };

        nixosConfigurations."mbk" = mkNixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/mbk ];
          hostname = "mbk";
        };

        nixosConfigurations."monitor" = mkNixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/monitor ];
          hostname = "monitor";
        };

        homeConfigurations = {
          "wil@drake" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              nixpkgsConf
              {
                home.username = "wil";
                home.homeDirectory = "/home/wil";
              }
              ./home
            ];
            extraSpecialArgs = { inherit inputs; };
          };
        };

        deploy.nodes = {
          wil-mac = {
            hostname = "wil-mac";
            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.wil-mac;
            };
          };

          mbk = {
            hostname = "mbk";
            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mbk;
            };
          };

          monitor = {
            hostname = "monitor";
            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.monitor;
            };
          };

          drake = {
            hostname = "drake";
            profiles.home = {
              user = "wil";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations."wil@drake";
            };
          };
        };

      };

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          };

          formatter = pkgs.nixfmt-tree;

          checks = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux (
            inputs.deploy-rs.lib.${pkgs.stdenv.hostPlatform.system}.deployChecks self.deploy
          );
        };
    };
}
