{
  directory,
  exclude ? [ ],
}:
let
  scan =
    relativeDirectory:
    let
      entries = builtins.readDir (directory + "/${relativeDirectory}");
    in
    builtins.concatMap (
      name:
      let
        relativePath = relativeDirectory + name;
        path = directory + "/${relativePath}";
        type = entries.${name};
      in
      if builtins.elem relativePath exclude then
        [ ]
      else if type == "directory" then
        if builtins.pathExists (path + "/default.nix") then [ path ] else scan "${relativePath}/"
      else if
        type == "regular"
        && name != "default.nix"
        && builtins.match ".*\\.nix" name != null
        && builtins.match ".*-test\\.nix" name == null
      then
        [ path ]
      else
        [ ]
    ) (builtins.attrNames entries);
in
scan ""
