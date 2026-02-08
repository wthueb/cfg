{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    i915-sriov = {
      url = "github:strongtz/i915-sriov-dkms?tag=2026.02.04";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:JafarAbdi/wezterm/render_fix?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # deduped inputs
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    btop = {
      url = "github:aristocratos/btop/main";
      flake = false;
    };
    catppuccin-btop = {
      url = "github:catppuccin/btop/main";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      determinate,
      home-manager,
      sops-nix,
      deploy-rs,
      flake-parts,
      treefmt-nix,
      ...
    }:
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
          name,
          hostname ? name,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            nixpkgsConf
            determinate.darwinModules.default
            sops-nix.darwinModules.sops
            home-manager.darwinModules.home-manager
            ./modules/common.nix
            ./modules/darwin
            ./hosts/${name}
            homeConfig
          ];
          specialArgs = { inherit self inputs hostname; };
        };

      mkNixosSystem =
        {
          system,
          name,
          hostname ? name,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixpkgsConf
            determinate.nixosModules.default
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./modules/common.nix
            ./modules/nixos
            ./hosts/${name}
            homeConfig
          ];
          specialArgs = { inherit self inputs hostname; };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ treefmt-nix.flakeModule ];

      flake = {
        darwinConfigurations.wil-mac = mkDarwinSystem {
          name = "wil-mac";
          system = "aarch64-darwin";
        };

        darwinConfigurations.osx = mkDarwinSystem {
          name = "osx";
          system = "x86_64-darwin";
        };

        nixosConfigurations.mbk = mkNixosSystem {
          name = "mbk";
          system = "x86_64-linux";
        };

        nixosConfigurations.monitor = mkNixosSystem {
          name = "monitor";
          system = "x86_64-linux";
        };

        nixosConfigurations.minecraft = mkNixosSystem {
          name = "minecraft";
          system = "x86_64-linux";
        };

        nixosConfigurations.iso = mkNixosSystem {
          name = "iso";
          hostname = "nixos";
          system = "x86_64-linux";
        };

        homeConfigurations = {
          "wil@drake" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              nixpkgsConf
              sops-nix.homeManagerModules.sops
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
              path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.wil-mac;
            };
          };

          mbk = {
            hostname = "mbk";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mbk;
            };
          };

          monitor = {
            hostname = "monitor";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.monitor;
            };
          };

          minecraft = {
            hostname = "minecraft";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.minecraft;
            };
          };

          drake = {
            hostname = "drake";
            profiles.home = {
              user = "wil";
              path = deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations."wil@drake";
            };
          };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

        packages.x86_64-linux.iso = self.nixosConfigurations.iso.config.system.build.isoImage;
      };

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, lib, ... }:
        {
          devShells = {
            default = pkgs.mkShell {
              packages = [
                deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
                pkgs.sops
              ];
            };

            sketchybar =
              let
                libs = with pkgs; [
                  sbarlua
                  lua54Packages.inspect
                ];
              in
              pkgs.mkShell {
                packages = [ pkgs.lua5_4 ] ++ libs;
                env = {
                  LUA_PATH = lib.concatMapStringsSep ";" pkgs.lua54Packages.getLuaPath libs;
                  LUA_CPATH = lib.concatMapStringsSep ";" pkgs.lua54Packages.getLuaCPath libs;
                };
              };

            powershell = pkgs.mkShell {
              packages = [
                pkgs.powershell
              ];
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";

            programs.nixfmt.enable = true;
            programs.stylua.enable = true;
          };
        };
    };
}
