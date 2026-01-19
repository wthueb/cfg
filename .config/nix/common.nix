{
  pkgs,
  hostname,
  ...
}:
{
  networking.hostName = hostname;

  environment = {
    shells = [
      pkgs.bashInteractive
      pkgs.nushell
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      bashInteractive
      coreutils
      curl
      fd
      file
      git
      gnugrep
      gnused
      gnutar
      neovim
      nil
      nushell
      rsync
      wget
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
  ];
}
