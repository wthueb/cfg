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
  programs.bash.profileExtra = lib.mkIf pkgs.stdenv.isDarwin (lib.mkAfter "exec nu");

  programs.nushell = {
    enable = true;
    configDir = "${config.xdg.configHome}/nushell/nix";
    extraLogin = ''
      load-env (
        open ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
        | lines
        | parse --regex 'export (?<var>\w+)=(?<val>.*)'
        | update val { from nuon }
        | transpose -r -d
      )
    '';
    plugins = with pkgs.nushellPlugins; [
      desktop_notifications
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
