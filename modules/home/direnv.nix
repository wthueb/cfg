{ config, lib, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = false;
      enableNushellIntegration = true;
    };

    bash.initExtra = ''
      if [[ -z ''${NIXPKGS_REVIEW_ROOT:-} ]]; then
        eval "$(${lib.getExe config.programs.direnv.package} hook bash)"
      fi
    '';
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
