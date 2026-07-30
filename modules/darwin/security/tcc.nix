{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.wthueb.security.tcc;

  indirectObjectType = types.submodule {
    options = {
      identifier = mkOption {
        type = types.str;
        description = "Bundle identifier of the Apple Events target.";
      };

      path = mkOption {
        type = types.str;
        description = "Path used to derive the Apple Events target's code requirement.";
      };
    };
  };

  permissionEntryType = types.submodule {
    options = {
      client = mkOption {
        type = types.str;
        description = "Executable whose canonical path must resolve into /nix/store.";
      };

      indirectObject = mkOption {
        type = types.nullOr indirectObjectType;
        default = null;
        description = "Required Apple Events target; invalid for other permissions.";
      };
    };
  };

  permissionValueType = types.coercedTo types.str (client: { inherit client; }) permissionEntryType;

  serviceSpecs = {
    accessibility = {
      scope = "system";
      service = "kTCCServiceAccessibility";
      authReason = 4;
      flags = 0;
      indirectType = 0;
    };
    inputMonitoring = {
      scope = "system";
      service = "kTCCServiceListenEvent";
      authReason = 4;
      flags = 0;
      indirectType = 0;
    };
    contacts = {
      scope = "user";
      service = "kTCCServiceAddressBook";
      authReason = 2;
      flags = 0;
      indirectType = null;
    };
    photos = {
      scope = "user";
      service = "kTCCServicePhotos";
      authReason = 2;
      flags = 16;
      indirectType = null;
    };
    microphone = {
      scope = "user";
      service = "kTCCServiceMicrophone";
      authReason = 2;
      flags = 0;
      indirectType = null;
    };
    appleEvents = {
      scope = "user";
      service = "kTCCServiceAppleEvents";
      authReason = 3;
      flags = null;
      indirectType = 0;
    };
  };

  permissionNames = builtins.attrNames cfg.permissions;
  unknownPermissionNames = builtins.filter (
    name: !(builtins.hasAttr name serviceSpecs)
  ) permissionNames;

  knownPermissions = lib.filterAttrs (name: _: builtins.hasAttr name serviceSpecs) cfg.permissions;
  expandedEntries = lib.concatLists (
    lib.mapAttrsToList (
      name: entries:
      map (
        entry:
        serviceSpecs.${name}
        // {
          inherit (entry) client indirectObject;
        }
      ) entries
    ) knownPermissions
  );

  appleEventsValid = builtins.all (entry: entry.indirectObject != null) (
    cfg.permissions.appleEvents or [ ]
  );
  otherIndirectObjectsAbsent =
    builtins.all (name: builtins.all (entry: entry.indirectObject == null) cfg.permissions.${name})
      (
        builtins.filter (name: name != "appleEvents" && builtins.hasAttr name serviceSpecs) permissionNames
      );

  primaryUser = config.system.primaryUser;
  userHome = if primaryUser == null then null else config.users.users.${primaryUser}.home;

  manifest = pkgs.writeText "nix-tcc-manifest.json" (builtins.toJSON expandedEntries);
  manager = pkgs.writeShellApplication {
    name = "nix-tcc-manager";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
      pkgs.sqlite
    ];
    text = builtins.readFile ./tcc-manager.sh;
  };

  systemDatabase = "/Library/Application Support/com.apple.TCC/TCC.db";
  userDatabase = "${userHome}/Library/Application Support/com.apple.TCC/TCC.db";
  managerArguments = lib.escapeShellArgs [
    "--manifest"
    manifest
    "--system-db"
    systemDatabase
    "--user-db"
    userDatabase
    "--user"
    primaryUser
  ];
in
{
  options.wthueb.security.tcc = {
    enable = lib.mkEnableOption "declarative TCC permissions for Nix store executables";

    permissions = mkOption {
      type = types.attrsOf (types.listOf permissionValueType);
      default = { };
      description = ''
        TCC permission entries keyed by accessibility, inputMonitoring, contacts,
        photos, microphone, or appleEvents. Simple entries may be executable paths;
        Apple Events entries must also declare an indirectObject.
      '';
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || primaryUser != null;
          message = "wthueb.security.tcc.enable requires system.primaryUser to be set";
        }
        {
          assertion = unknownPermissionNames == [ ];
          message = "unsupported wthueb.security.tcc permission(s): ${lib.concatStringsSep ", " unknownPermissionNames}";
        }
        {
          assertion = appleEventsValid;
          message = "every wthueb.security.tcc.permissions.appleEvents entry requires indirectObject";
        }
        {
          assertion = otherIndirectObjectsAbsent;
          message = "indirectObject is only valid for wthueb.security.tcc.permissions.appleEvents";
        }
      ];

      system.build = {
        tccManager = manager;
        tccManifest = manifest;
      };
    }
    (lib.mkIf cfg.enable {
      system.activationScripts.checks.text = lib.mkAfter ''
        ${manager}/bin/nix-tcc-manager check ${managerArguments}
      '';

      system.activationScripts.extraActivation.text = lib.mkAfter ''
        (
          liveRoots=$(mktemp "''${TMPDIR:-/tmp}/nix-tcc-live-roots.XXXXXX")
          trap 'rm -f -- "$liveRoots"' EXIT
          if ! nixStore=$(command -v nix-store); then
            echo "error: wthueb.security.tcc could not find nix-store in the activation PATH" >&2
            exit 1
          fi
          "$nixStore" -qR "$systemConfig" >"$liveRoots"
          ${manager}/bin/nix-tcc-manager apply ${managerArguments} --live-roots "$liveRoots"
        )
      '';
    })
  ];
}
