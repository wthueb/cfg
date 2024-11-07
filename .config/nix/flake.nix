{
  description = "wthueb's macbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
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
          inherit self;
          inherit inputs;
        };
      };

      darwinPackages = self.darwinConfigurations."wil-mac".pkgs;
    };
}
