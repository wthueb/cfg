{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      inputs.flake-compat.follows = "flake-compat";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    i915-sriov = {
      url = "github:strongtz/i915-sriov-dkms?tag=2026.05.06";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.systems.follows = "systems";
    };

    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # utilities
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # non-flakes
    btop = {
      url = "github:aristocratos/btop/main";
      flake = false;
    };
    catppuccin-btop = {
      url = "github:catppuccin/btop/main";
      flake = false;
    };
    catppuccin-neomutt = {
      url = "github:catppuccin/neomutt/main";
      flake = false;
    };

    # deduped inputs
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      deploy-rs,
      flake-parts,
      treefmt-nix,
      disko,
      ...
    }@inputs:
    let
      nixpkgsConfig = {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = (import ./overlays.nix { inherit self inputs; }) ++ [ self.overlays.default ];
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

      mkSystem = import ./lib/mkSystem.nix {
        inherit
          self
          inputs
          nixpkgsConfig
          homeConfig
          ;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ treefmt-nix.flakeModule ];

      flake = {
        darwinConfigurations.wil-mac = mkSystem {
          name = "wil-mac";
          system = "aarch64-darwin";
        };

        nixosConfigurations.mbk = mkSystem {
          name = "mbk";
          system = "x86_64-linux";
        };

        nixosConfigurations.ida = mkSystem {
          name = "ida";
          system = "x86_64-linux";
        };

        nixosConfigurations.minecraft = mkSystem {
          name = "minecraft";
          system = "x86_64-linux";
        };

        nixosConfigurations.shell = mkSystem {
          name = "shell";
          system = "x86_64-linux";
        };

        nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            {
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              environment.systemPackages = [
                disko.packages.x86_64-linux.disko-install
              ];

              services.openssh = {
                enable = true;
                settings.PermitRootLogin = "prohibit-password";
              };

              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAlhysK1b0FyyN0XXKf8BR76UIZGHiVnMUPNjYmuJ6k wil@wil-mac"
              ];
            }
          ];
        };

        packages.x86_64-linux.iso = self.nixosConfigurations.iso.config.system.build.isoImage;

        homeConfigurations = {
          "wil@drake" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              nixpkgsConfig
              {
                home = {
                  username = "wil";
                  homeDirectory = "/home/wil";
                };

                wthueb.video.enable = true;
              }
              ./home
            ];
            extraSpecialArgs = { inherit inputs; };
          };

          "wil@nate" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              nixpkgsConfig
              {
                home = {
                  username = "wil";
                  homeDirectory = "/home/wil";
                };

                wthueb.video.enable = true;
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

          ida = {
            hostname = "ida";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.ida;
            };
          };

          minecraft = {
            hostname = "minecraft";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.minecraft;
            };
          };

          shell = {
            hostname = "shell";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.shell;
            };
          };

          drake = {
            hostname = "drake";
            profiles.home = {
              user = "wil";
              path = deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations."wil@drake";
            };
          };

          nate = {
            hostname = "nate";
            profiles.home = {
              user = "wil";
              path = deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations."wil@nate";
            };
          };
        };

        overlays.default =
          final: prev:
          builtins.listToAttrs (
            builtins.map (file: {
              name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
              value = final.callPackage ./packages/${file} { };
            }) (builtins.attrNames (builtins.readDir ./packages))
          );

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs (
            {
              inherit system;
            }
            // nixpkgsConfig.nixpkgs
          );

          packages =
            let
              packageNames = builtins.map (f: lib.removeSuffix ".nix" f) (
                builtins.attrNames (builtins.readDir ./packages)
              );
            in
            lib.genAttrs packageNames (name: pkgs.${name});

          devShells = {
            default = pkgs.mkShell {
              packages = [
                deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
                pkgs.sops
                pkgs.grafana-alloy
              ];
            };

            sketchybar =
              let
                cfg = self.darwinConfigurations.wil-mac.config.home-manager.users.wil.programs.sketchybar;
                luaPackages = cfg.luaPackage.pkgs;
                libs = [
                  cfg.sbarLuaPackage
                  luaPackages.inspect
                ];
              in
              pkgs.mkShell {
                packages = [ cfg.luaPackage ] ++ libs;
                env = {
                  LUA_PATH = lib.concatMapStringsSep ";" luaPackages.getLuaPath libs;
                  LUA_CPATH = lib.concatMapStringsSep ";" luaPackages.getLuaCPath libs;
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

            settings.formatter.alloy = {
              command = lib.getExe pkgs.bash;
              options = [
                "-euc"
                ''
                  for file in "$@"; do
                    ${lib.getExe pkgs.grafana-alloy} fmt --write "$file"
                  done
                ''
                "--"
              ];
              includes = [ "*.alloy" ];
            };
          };
        };
    };
}
