{ pkgs, tccManager }:
pkgs.runCommand "tcc-manager-test"
  {
    nativeBuildInputs = [
      tccManager
      pkgs.coreutils
      pkgs.jq
      pkgs.sqlite
    ];
  }
  ''
    set -euo pipefail

    fixtureDir=$TMPDIR/tcc-fixtures
    mkdir -p "$fixtureDir"

    makeDb() {
      local database=$1
      sqlite3 "$database" <<'SQL'
    CREATE TABLE policies (
      id INTEGER PRIMARY KEY
    );
    CREATE TABLE access (
      service TEXT NOT NULL,
      client TEXT NOT NULL,
      client_type INTEGER NOT NULL,
      auth_value INTEGER NOT NULL,
      auth_reason INTEGER NOT NULL,
      auth_version INTEGER NOT NULL,
      csreq BLOB,
      policy_id INTEGER,
      indirect_object_identifier_type INTEGER,
      indirect_object_identifier TEXT NOT NULL DEFAULT 'UNUSED',
      indirect_object_code_identity BLOB,
      flags INTEGER,
      last_modified INTEGER NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER)),
      pid INTEGER,
      pid_version INTEGER,
      boot_uuid TEXT NOT NULL DEFAULT 'UNUSED',
      last_reminded INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (service, client, client_type, indirect_object_identifier),
      FOREIGN KEY (policy_id) REFERENCES policies(id) ON DELETE CASCADE ON UPDATE CASCADE
    );
    SQL
    }

    systemDb="$fixtureDir/system.db"
    userDb="$fixtureDir/user.db"
    makeDb "$systemDb"
    makeDb "$userDb"

    staleClient=/nix/store/00000000000000000000000000000000-stale/bin/stale
    liveClient=${pkgs.coreutils}/bin/true
    desiredClient=${pkgs.hello}/bin/hello
    shellClient=${pkgs.runtimeShell}

    sqlite3 "$systemDb" <<SQL
    INSERT INTO access
      (service, client, client_type, auth_value, auth_reason, auth_version, csreq,
       indirect_object_identifier_type, indirect_object_identifier, flags)
    VALUES
      ('kTCCServiceAccessibility', '$staleClient', 1, 2, 4, 1, X'00', 0, 'UNUSED', 0),
      ('kTCCServiceAccessibility', '$liveClient', 1, 2, 4, 1, X'00', 0, 'UNUSED', 0),
      ('kTCCServiceAccessibility', '$desiredClient', 1, 0, 0, 1, X'00', 0, 'UNUSED', 0),
      ('kTCCServiceAccessibility', '/Applications/Keep.app/Contents/MacOS/Keep', 1, 2, 4, 1, X'CAFE', 0, 'UNUSED', 0),
      ('kTCCServiceAccessibility', 'com.example.keep', 0, 2, 4, 1, X'BEEF', 0, 'UNUSED', 0);
    SQL

    sqlite3 "$userDb" <<SQL
    INSERT INTO access
      (service, client, client_type, auth_value, auth_reason, auth_version, csreq,
       indirect_object_identifier, flags)
    VALUES
      ('kTCCServicePhotos', '$staleClient', 1, 2, 2, 1, X'00', 'UNUSED', 16),
      ('kTCCServiceMicrophone', '/Applications/Keep.app/Contents/MacOS/Keep', 1, 2, 2, 1, X'CAFE', 'UNUSED', 0),
      ('kTCCServiceMicrophone', 'com.example.keep', 0, 2, 2, 1, X'BEEF', 'UNUSED', 0);
    SQL

    manifest="$fixtureDir/manifest.json"
    cat >"$manifest" <<JSON
    [
      {
        "scope": "system",
        "service": "kTCCServiceAccessibility",
        "client": "$desiredClient",
        "authReason": 4,
        "flags": 0,
        "indirectType": 0,
        "indirectObject": null
      },
      {
        "scope": "user",
        "service": "kTCCServiceAddressBook",
        "client": "$shellClient",
        "authReason": 2,
        "flags": 0,
        "indirectType": null,
        "indirectObject": null
      },
      {
        "scope": "user",
        "service": "kTCCServicePhotos",
        "client": "$desiredClient",
        "authReason": 2,
        "flags": 16,
        "indirectType": null,
        "indirectObject": null
      },
      {
        "scope": "user",
        "service": "kTCCServiceAppleEvents",
        "client": "$desiredClient",
        "authReason": 3,
        "flags": null,
        "indirectType": 0,
        "indirectObject": {
          "identifier": "com.apple.systemevents",
          "path": "/System/Library/CoreServices/System Events.app"
        }
      }
    ]
    JSON

    liveRoots="$fixtureDir/live-roots"
    cat >"$liveRoots" <<ROOTS
    ${pkgs.coreutils}
    ${pkgs.hello}
    ${pkgs.runtimeShellPackage}
    ROOTS

    globalDisabled="$fixtureDir/csr-global-disabled"
    customDisabled="$fixtureDir/csr-custom-disabled"
    enabled="$fixtureDir/csr-enabled"
    customEnabled="$fixtureDir/csr-custom-enabled"

    printf '%s\n' 'System Integrity Protection status: disabled.' >"$globalDisabled"
    cat >"$customDisabled" <<'STATUS'
    System Integrity Protection status: unknown (Custom Configuration).
    Configuration:
            Filesystem Protections: disabled
            Authenticated Root Requirement: enabled
    STATUS
    printf '%s\n' 'System Integrity Protection status: enabled.' >"$enabled"
    cat >"$customEnabled" <<'STATUS'
    System Integrity Protection status: unknown (Custom Configuration).
    Configuration:
            Filesystem Protections: enabled
    STATUS

    testUser=$(id -un)
    managerArgs=(
      --manifest "$manifest"
      --system-db "$systemDb"
      --user-db "$userDb"
      --user "$testUser"
    )

    initialSystemHash=$(sha256sum "$systemDb")
    initialUserHash=$(sha256sum "$userDb")
    nix-tcc-manager check "''${managerArgs[@]}" --csr-status-file "$globalDisabled"
    nix-tcc-manager check "''${managerArgs[@]}" --csr-status-file "$customDisabled"
    [[ "$(sha256sum "$systemDb")" == "$initialSystemHash" ]]
    [[ "$(sha256sum "$userDb")" == "$initialUserHash" ]]

    if nix-tcc-manager check "''${managerArgs[@]}" --csr-status-file "$enabled" >/dev/null 2>&1; then
      echo 'enabled SIP unexpectedly passed preflight' >&2
      exit 1
    fi
    if nix-tcc-manager check "''${managerArgs[@]}" --csr-status-file "$customEnabled" >/dev/null 2>&1; then
      echo 'custom SIP with filesystem protection unexpectedly passed preflight' >&2
      exit 1
    fi

    readonlyDb="$fixtureDir/readonly.db"
    cp "$systemDb" "$readonlyDb"
    chmod 0444 "$readonlyDb"
    if nix-tcc-manager check \
      --manifest "$manifest" \
      --system-db "$readonlyDb" \
      --user-db "$userDb" \
      --user "$testUser" \
      --csr-status-file "$customDisabled" >/dev/null 2>&1; then
      echo 'read-only database unexpectedly passed preflight' >&2
      exit 1
    fi

    systemNonNixBefore=$(sqlite3 "$systemDb" \
      "SELECT quote(service || '|' || client || '|' || client_type || '|' || auth_value || '|' || auth_reason || '|' || hex(csreq)) FROM access WHERE client NOT GLOB '/nix/store/*' ORDER BY client;")
    userNonNixBefore=$(sqlite3 "$userDb" \
      "SELECT quote(service || '|' || client || '|' || client_type || '|' || auth_value || '|' || auth_reason || '|' || hex(csreq)) FROM access WHERE client NOT GLOB '/nix/store/*' ORDER BY client;")

    nix-tcc-manager apply \
      "''${managerArgs[@]}" \
      --live-roots "$liveRoots" \
      --csr-status-file "$customDisabled" \
      --no-reload

    [[ "$(sqlite3 "$systemDb" "SELECT count(*) FROM access WHERE client = '$staleClient';")" == 0 ]]
    [[ "$(sqlite3 "$userDb" "SELECT count(*) FROM access WHERE client = '$staleClient';")" == 0 ]]
    [[ "$(sqlite3 "$systemDb" "SELECT count(*) FROM access WHERE client = '$liveClient';")" == 1 ]]
    [[ "$(sqlite3 "$systemDb" "SELECT count(*) FROM access WHERE client = '$desiredClient' AND auth_value = 2 AND auth_reason = 4 AND flags = 0 AND length(csreq) > 0;")" == 1 ]]
    [[ "$(sqlite3 "$userDb" "SELECT count(*) FROM access WHERE client = '$shellClient' AND service = 'kTCCServiceAddressBook' AND auth_reason = 2 AND flags = 0 AND length(csreq) > 0;")" == 1 ]]
    [[ "$(sqlite3 "$userDb" "SELECT count(*) FROM access WHERE client = '$desiredClient' AND service = 'kTCCServicePhotos' AND flags = 16 AND length(csreq) > 0;")" == 1 ]]
    [[ "$(sqlite3 "$userDb" "SELECT count(*) FROM access WHERE client = '$desiredClient' AND service = 'kTCCServiceAppleEvents' AND indirect_object_identifier = 'com.apple.systemevents' AND length(indirect_object_code_identity) > 0;")" == 1 ]]

    systemNonNixAfter=$(sqlite3 "$systemDb" \
      "SELECT quote(service || '|' || client || '|' || client_type || '|' || auth_value || '|' || auth_reason || '|' || hex(csreq)) FROM access WHERE client NOT GLOB '/nix/store/*' ORDER BY client;")
    userNonNixAfter=$(sqlite3 "$userDb" \
      "SELECT quote(service || '|' || client || '|' || client_type || '|' || auth_value || '|' || auth_reason || '|' || hex(csreq)) FROM access WHERE client NOT GLOB '/nix/store/*' ORDER BY client;")
    [[ "$systemNonNixAfter" == "$systemNonNixBefore" ]]
    [[ "$userNonNixAfter" == "$userNonNixBefore" ]]
    [[ "$(sqlite3 "$systemDb" 'PRAGMA quick_check;')" == ok ]]
    [[ "$(sqlite3 "$userDb" 'PRAGMA quick_check;')" == ok ]]

    secondRun=$(nix-tcc-manager apply \
      "''${managerArgs[@]}" \
      --live-roots "$liveRoots" \
      --csr-status-file "$customDisabled" \
      --no-reload)
    grep -Fq 'TCC reconciliation changed 0 row(s)' <<<"$secondRun"

    brokenDb="$fixtureDir/broken.db"
    sqlite3 "$brokenDb" 'CREATE TABLE access (service TEXT);'
    systemHashBeforeFailure=$(sha256sum "$systemDb")
    if nix-tcc-manager apply \
      --manifest "$manifest" \
      --system-db "$systemDb" \
      --user-db "$brokenDb" \
      --user "$testUser" \
      --live-roots "$liveRoots" \
      --csr-status-file "$customDisabled" \
      --no-reload >/dev/null 2>&1; then
      echo 'invalid user schema unexpectedly passed preflight' >&2
      exit 1
    fi
    [[ "$(sha256sum "$systemDb")" == "$systemHashBeforeFailure" ]]

    nonStoreManifest="$fixtureDir/non-store-manifest.json"
    jq '.[0].client = "/bin/sh"' \
      "$manifest" >"$nonStoreManifest"
    systemHashBeforeFailure=$(sha256sum "$systemDb")
    userHashBeforeFailure=$(sha256sum "$userDb")
    if nix-tcc-manager apply \
      --manifest "$nonStoreManifest" \
      --system-db "$systemDb" \
      --user-db "$userDb" \
      --user "$testUser" \
      --live-roots "$liveRoots" \
      --csr-status-file "$customDisabled" \
      --no-reload >/dev/null 2>&1; then
      echo 'non-Nix configured client unexpectedly passed preflight' >&2
      exit 1
    fi
    [[ "$(sha256sum "$systemDb")" == "$systemHashBeforeFailure" ]]
    [[ "$(sha256sum "$userDb")" == "$userHashBeforeFailure" ]]

    malformedAppleEventsManifest="$fixtureDir/malformed-apple-events-manifest.json"
    jq 'map(if .service == "kTCCServiceAppleEvents" then .indirectObject = null else . end)' \
      "$manifest" >"$malformedAppleEventsManifest"
    systemHashBeforeFailure=$(sha256sum "$systemDb")
    userHashBeforeFailure=$(sha256sum "$userDb")
    if nix-tcc-manager apply \
      --manifest "$malformedAppleEventsManifest" \
      --system-db "$systemDb" \
      --user-db "$userDb" \
      --user "$testUser" \
      --live-roots "$liveRoots" \
      --csr-status-file "$customDisabled" \
      --no-reload >/dev/null 2>&1; then
      echo 'Apple Events entry without a target unexpectedly passed preflight' >&2
      exit 1
    fi
    [[ "$(sha256sum "$systemDb")" == "$systemHashBeforeFailure" ]]
    [[ "$(sha256sum "$userDb")" == "$userHashBeforeFailure" ]]

    touch "$out"
  ''
