{
  config,
  pkgs,
  lib,
  ...
}:
{
  # nushell isn't supported directly as a login shell via nix-darwin, so we just use bash
  # and launch nushell from it instead (only as a login shell so we can still use bash normally)
  # see nix-darwin/nix-darwin#1028
  programs.bash.profileExtra = lib.mkIf pkgs.stdenv.isDarwin (
    lib.mkAfter "[[ $- == *i* ]] && exec nu"
  );

  programs.nushell = {
    enable = true;
    configDir = "${config.xdg.configHome}/nushell/nix";
    extraLogin = ''
      let hm_file = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"
      let hm_names = (
        open $hm_file
        | lines
        | parse --regex '^\s*export (?<n>\w+)='
        | get n
        | uniq
      )
      mut hm_vars = (
        ^${pkgs.bash}/bin/bash -c '
          file="$1"; shift
          unset __HM_SESS_VARS_SOURCED
          . "$file"
          for name in "$@"; do
            printf "%s=%s\n" "$name" "''${!name}"
          done
        ' bash $hm_file ...$hm_names
        | lines
        | parse --regex '^(?<name>[^=]+)=(?<value>.*)$'
        | reduce --fold {} { |row, acc| $acc | insert $row.name $row.value }
      )
      if "PATH" in ($hm_vars | columns) {
        $hm_vars.PATH = ($hm_vars.PATH | split row (char esep) | path expand --no-symlink | uniq)
      }
      load-env $hm_vars
    '';
    extraEnv = ''
      $env.NIXPKGS_ALLOW_UNFREE = 1
    '';
    plugins = with pkgs.nushellPlugins; [
      formats
      polars
      query
    ];
  };

  home.file = {
    "${config.xdg.configHome}/nushell/login.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.programs.nushell.configDir}/login.nu";
    "${config.xdg.configHome}/nushell/plugin.msgpackz".source =
      config.lib.file.mkOutOfStoreSymlink "${config.programs.nushell.configDir}/plugin.msgpackz";
  };
}
