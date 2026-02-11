{
  self,
  inputs,
  nixpkgsConfig,
  homeConfig,
}:
{
  system,
  name,
  hostname ? name,
}:
let
  parsedSystem = builtins.match "^.+-(linux|darwin)$" system;

  systemType = builtins.head parsedSystem;

  os =
    if systemType == "linux" then
      "nixos"
    else if systemType == "darwin" then
      "darwin"
    else
      throw "unsupported system: ${system}";

  systemFunc =
    if os == "nixos" then
      inputs.nixpkgs.lib.nixosSystem
    else if os == "darwin" then
      inputs.nix-darwin.lib.darwinSystem
    else
      throw "unsupported system: ${system}";

  modulesName = "${os}Modules";
in
assert
  parsedSystem != null && builtins.length parsedSystem == 1
  || throw "unrecognized system format: ${system}";

systemFunc {
  inherit system;
  modules = [
    nixpkgsConfig
    inputs.determinate.${modulesName}.default
    inputs.sops-nix.${modulesName}.default
    inputs.home-manager.${modulesName}.default
    ../modules/common.nix
    ../modules/${os}
    ../hosts/${name}
    homeConfig
  ];
  specialArgs = { inherit self inputs hostname; };
}
