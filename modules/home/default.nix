{
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ (import ../../lib/module-imports.nix { directory = ./.; })
  ++ (import ../../lib/features.nix).importsFor "home";
}
