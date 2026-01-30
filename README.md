# my nix flake/dotfiles

to install:

nix systems:

```bash
git clone https://github.com/wthueb/cfg.git ~/.cfg

# and one of the following:
# sudo darwin-rebuild switch --flake ~/.cfg
# sudo nixos-rebuild switch --flake ~/.cfg
# nix run nixpkgs#release-XX.XX -- switch --flake ~/.cfg
```

windows systems:

1. install [scoop](https://scoop.sh)
2. `scoop install git nu`
3. in `nu`:
    ```nushell
    git clone https://github.com/wthueb/cfg.git ~/.cfg
    ~/.cfg/windows-install.nu
    ```

---

effectively, all cross-platform/windows-specific stuff isn't managed by home-manager and is just in /dotfiles how it would go in the home directory. everything else is managed by nixos/nix-darwin/home-manager, assuming the modules exist
