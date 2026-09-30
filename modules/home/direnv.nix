{ ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  xdg.configFile."direnv/lib/zzz-restore-login-shell.sh".text = ''
    if declare -f use_flake >/dev/null; then
      eval "_direnv_orig_use_flake() $(declare -f use_flake | tail -n +2)"
      use_flake() {
        _direnv_orig_use_flake "$@"
        # unsetting shell fixes nested nix shells using uninteractive bash
        unset shell
      }
    fi
  '';
}
