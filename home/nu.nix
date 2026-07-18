{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nushell = {
    enable = true;
    configDir = "${config.xdg.configHome}/nushell/nix";
    envFile.text = ''
      let vars = (
        ${lib.getExe pkgs.bashInteractive} -lic ${lib.getExe' pkgs.coreutils "env"}
        | lines
        | parse --regex '^(?<name>[^=]+)=(?<value>.*)$'
        | where name !~ '^(_|FILE_PWD|PWD|OLDPWD|SHELL|SHLVL|CURRENT_FILE|STARSHIP_SESSION_KEY|PROMPT_COMMAND.*|PROMPT.*INDICATOR)$'
        | reduce --fold {} {|row, acc| $acc | upsert $row.name $row.value }
        | update PATH { split row (char esep) | path expand --no-symlink | uniq }
      )
      load-env $vars

      $env.NIXPKGS_ALLOW_UNFREE = 1
    '';
    plugins = with pkgs.nushellPlugins; [
      formats
      polars
      query
    ];
  };

  home.file = {
    "${config.xdg.configHome}/nushell/plugin.msgpackz".source =
      config.lib.file.mkOutOfStoreSymlink "${config.programs.nushell.configDir}/plugin.msgpackz";
  };
}
