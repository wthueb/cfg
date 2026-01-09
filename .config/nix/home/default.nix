{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./nu.nix
  ];

  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
    dates = "weekly";
    persistent = true;
  };

  home.packages = with pkgs; [
    delta
    dig
    dua
    gh
    gnugrep
    gnumake
    gnused
    gnutar
    jc
    nixfmt-rfc-style
    nodejs
    opencode
    openssh
    python3
    rsync
    rustup
    tmux
    tree
    unzip
  ];

  programs = {
    bash.enable = true;
    bat.enable = true;
    btop = {
      enable = true;
      settings = {
        color_theme = "nord";
        vim_keys = true;
        proc_per_core = true;
      };
      themes = {
        nord = builtins.readFile "${inputs.btop}/themes/nord.theme";
      };
    };
    carapace.enable = true;
    dircolors.enable = true;
    direnv.enable = true;
    discord = {
      enable = true;
      settings = {
        SKIP_HOST_UPDATE = true;
        DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
      };
    };
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    jq.enable = true;
    less = {
      enable = true;
      config = ''
        #command
        j forw-line
        k back-line
        l right-scroll
        h left-scroll

        / forw-search
        ? back-search
        n repeat-search
        N reverse-search

        f forw-screen
        b back-screen
        d forw-scroll
        u back-scroll
      '';
    };
    neovim.enable = true;
    readline = {
      enable = true;
      extraConfig = ''
        set editing-mode vi
        set keymap vi
        set show-mode-in-prompt on
        set vi-ins-mode-string \1\e[2 q\2
        set vi-cmd-mode-string \1\e[4 q\2

        set colored-stats On
        set completion-ignore-case On
        set completion-prefix-display-length 3
        set mark-symlinked-directories On
        set show-all-if-ambiguous On
        set show-all-if-unmodified On
        set visible-stats On
      '';
    };
    ripgrep.enable = true;
    starship.enable = true;
    tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };
    uv.enable = true;
    wezterm.enable = true;
  };

  home.shell.enableShellIntegration = true;

  services = {
    skhd.enable = pkgs.stdenv.isDarwin;
    ssh-agent.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.enable = true;

  home.stateVersion = "24.11";
}
