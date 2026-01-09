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

    i915-sriov = {
      url = "github:strongtz/i915-sriov-dkms?ref=2025.12.10";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    btop = {
      url = "github:aristocratos/btop/main";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      nixpkgsConf = {
        nixpkgs = {
          config.allowUnfree = true;
          overlays =
            let
              fromUnstable = pkg: final: prev: {
                ${pkg} = inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system}.${pkg};
              };
            in
            [
              (fromUnstable "carapace")
              (fromUnstable "neovim")
              (fromUnstable "nushell")
              (fromUnstable "opencode")
              (fromUnstable "starship")
              (fromUnstable "wezterm")
              (final: prev: {
                nushellPlugins = prev.nushellPlugins // {
                  desktop_notifications = prev.nushellPlugins.desktop_notifications.overrideAttrs (old: rec {
                    version = "0.109.1";
                    src = final.fetchFromGitHub {
                      owner = "FMotalleb";
                      repo = "nu_plugin_desktop_notifications";
                      tag = "v${version}";
                      hash = "sha256-eNdaaOgQWd5qZQG9kypzpMsHiKX7J5BXPSsNLJYCVTo=";
                    };
                    cargoDeps = final.rustPlatform.fetchCargoVendor {
                      inherit src;
                      hash = "sha256-Mo+v3725jVNTCy7qjvTnDDN2JSAI48tpPCoQoewo4wM=";
                    };
                    meta.platforms = final.lib.platforms.linux ++ final.lib.platforms.darwin;
                  });
                };
              })
            ];
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
    in
    {
      darwinConfigurations."wil-mac" = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          nixpkgsConf
          ./common.nix
          ./wil-mac/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          homeConfig
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "wil-mac";
        };
      };

      darwinConfigurations."osx" = inputs.nixpkgs.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          nixpkgsConf
          ./common.nix
          ./osx/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          homeConfig
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "osx";
        };
      };

      nixosConfigurations."mbk" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgsConf
          ./common.nix
          ./modules/nixos.nix
          ./mbk/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          homeConfig
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "mbk";
        };
      };

      nixosConfigurations."monitor" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86-linux";
        modules = [
          nixpkgsConf
          ./common.nix
          ./modules/nixos.nix
          ./monitor/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          homeConfig
        ];
        specialArgs = {
          inherit self inputs;
          hostname = "monitor";
        };
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
    };
}
