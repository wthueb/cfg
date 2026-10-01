{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wthueb.services.kanata;
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  kanata = cfg.package;
  driver = cfg.driverPackage;
  driverDirectory = "/Applications/.Nix-Kanata";
  managerApp = ".Karabiner-VirtualHIDDevice-Manager.app";
  manager = "${driverDirectory}/${managerApp}/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  installDriver = pkgs.writeShellScript "install-kanata-driver" ''
    set -euo pipefail
    /bin/mkdir -p ${driverDirectory}
    if [[ ! -d ${driverDirectory}/${managerApp} ]] || \
       [[ ! -f ${driverDirectory}/.driver-package ]] || \
       [[ "$(<${driverDirectory}/.driver-package)" != ${lib.escapeShellArg (toString driver)} ]]; then
      staging=$(/usr/bin/mktemp -d ${driverDirectory}/.install.XXXXXX)
      trap '/bin/rm -rf "$staging"' EXIT
      /bin/cp -R ${lib.escapeShellArg "${driver}/Applications/${managerApp}"} "$staging/${managerApp}"
      /bin/chmod -R u+w "$staging/${managerApp}"
      /usr/bin/codesign --verify --deep --strict "$staging/${managerApp}"
      /bin/rm -rf ${driverDirectory}/${managerApp}
      /bin/mv "$staging/${managerApp}" ${driverDirectory}/${managerApp}
      printf '%s\n' ${lib.escapeShellArg (toString driver)} > ${driverDirectory}/.driver-package
    fi
  '';
  startDriver = pkgs.writeShellScript "kanata-driver-start" ''
    set -euo pipefail
    ${installDriver}
    ${manager} forceActivate
    for label in org.nixos.kanata-vhid org.nixos.kanata; do
      if /bin/launchctl print "system/$label" >/dev/null 2>&1; then
        /bin/launchctl bootout "system/$label"
      fi
      /bin/launchctl bootstrap system "/Library/LaunchDaemons/$label.plist"
    done
  '';
  configuration = pkgs.writeText "kanata.kbd" cfg.config;
in
{
  options.wthueb.services.kanata = {
    enable = lib.mkEnableOption "Kanata keyboard remapping";

    package = lib.mkPackageOption pkgs "kanata" { };

    driverPackage = lib.mkOption {
      type = lib.types.package;
      default = cfg.package.darwinDriver;
      defaultText = lib.literalExpression "config.wthueb.services.kanata.package.darwinDriver";
      description = "Karabiner DriverKit virtual-HID package used by Kanata.";
    };

    config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Kanata keyboard configuration.";
    };

    logDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${home}/Library/Logs";
      defaultText = lib.literalExpression "\"\${config.users.users.\${config.system.primaryUser}.home}/Library/Logs\"";
      description = "Directory for Kanata and virtual-HID driver logs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = user != null;
        message = "wthueb.services.kanata requires system.primaryUser to be set";
      }
      {
        assertion = cfg.config != "";
        message = "wthueb.services.kanata requires a non-empty config";
      }
    ];

    environment.etc."kanata/kanata.kbd".source = configuration;

    system.activationScripts.preActivation.text = lib.mkAfter ''
      ${installDriver}
    '';

    launchd.daemons.kanata-driver = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path /nix/store && exec ${startDriver}"
        ];
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        StandardOutPath = "${cfg.logDirectory}/kanata-driver.log";
        StandardErrorPath = "${cfg.logDirectory}/kanata-driver.log";
      };
    };

    launchd.daemons.kanata-vhid.serviceConfig = {
      ProgramArguments = [
        "${driver}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${cfg.logDirectory}/kanata-vhid.log";
      StandardErrorPath = "${cfg.logDirectory}/kanata-vhid.log";
    };

    launchd.daemons.kanata.serviceConfig = {
      ProgramArguments = [
        (lib.getExe kanata)
        "--cfg"
        (toString configuration)
        "--no-wait"
      ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      StandardOutPath = "${cfg.logDirectory}/kanata.log";
      StandardErrorPath = "${cfg.logDirectory}/kanata.log";
    };

    system.build = {
      inherit kanata;
      kanataDriver = driver;
      kanataDriverInstaller = installDriver;
      kanataConfig = configuration;
      kanataConfigCheck = pkgs.runCommand "kanata-config-check" { } ''
        ${lib.getExe kanata} --check --cfg ${configuration}
        touch "$out"
      '';
    };
  };
}
