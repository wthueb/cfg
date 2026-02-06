{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./nu.nix
    ./sketchybar
    ./skhd
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
    jc
    nerd-fonts.fira-code
    nerd-fonts.sauce-code-pro
    nil
    nixfmt-rfc-style
    opencode
    openssh
    tree
    tree-sitter
    unzip
    vivid
  ];

  fonts.fontconfig.enable = true;

  programs = {
    bash = {
      enable = true;
      profileExtra = ''
        [[ -f ~/.profile.custom ]] && source ~/.profile.custom
      '';
    };
    bat.enable = true;
    btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin";
        vim_keys = true;
        proc_per_core = true;
      };
      themes = {
        catppuccin = builtins.readFile "${inputs.catppuccin-btop}/themes/catppuccin_mocha.theme";
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
    gh = {
      enable = true;
      extensions = [ pkgs.gh-markdown-preview ];
    };
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
    neovim = {
      enable = true;
      extraPackages = [
        pkgs.nodejs
        pkgs.python3
      ];
    };
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
    tmux = {
      enable = true;
      keyMode = "vi";
      prefix = "C-b";
      focusEvents = true;
      mouse = true;
      baseIndex = 1;
      sensibleOnTop = true;
      extraConfig = ''
        # the PATH and such gets screwed on macos due to our bash -> nushell
        # startup stuff if we use a login shell in tmux
        set-option -g default-command "''${SHELL}"
      '';
      plugins = with pkgs.tmuxPlugins; [
        sensible
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'mocha'
          '';
        }
      ];
    };
    uv.enable = true;
    wezterm.enable = true;
  };

  home.shell.enableShellIntegration = true;

  services = {
    ssh-agent.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.enable = true;

  home.file =
    let
      listFilesRecursive =
        rootDir: relativePath:
        lib.flatten (
          lib.mapAttrsToList (
            basename: type:
            if type == "regular" then
              "${relativePath}${basename}"
            else
              listFilesRecursive rootDir "${relativePath}${basename}/"
          ) (builtins.readDir "${rootDir}/${relativePath}")
        );

      toHomeFiles =
        rootDir:
        builtins.listToAttrs (
          map (relativePath: {
            name = relativePath;
            value = {
              source = "${rootDir}/${relativePath}";
            };
          }) (listFilesRecursive rootDir "")
        );
    in
    toHomeFiles ../dotfiles;

  home.stateVersion = "24.11";
}
