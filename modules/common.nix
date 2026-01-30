{
  pkgs,
  hostname,
  ...
}:
{
  networking.hostName = hostname;

  environment = {
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
      nushell
      rsync
      wget
    ];
    shells = [
      pkgs.bashInteractive
      pkgs.nushell
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  services.tailscale.enable = true;

  users.users.wil.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAlhysK1b0FyyN0XXKf8BR76UIZGHiVnMUPNjYmuJ6k wil@wil-mac"
  ];
}
