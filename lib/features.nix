let
  featuresDir = ../modules/features;
  entries = builtins.readDir featuresDir;
  names = builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);
  fileIfExists = p: if builtins.pathExists p then [ p ] else [ ];
in
{
  inherit names;

  importsFor =
    scope:
    builtins.concatMap (
      n:
      fileIfExists (featuresDir + "/${n}/options.nix")
      ++ fileIfExists (featuresDir + "/${n}/${scope}.nix")
    ) names;
}
