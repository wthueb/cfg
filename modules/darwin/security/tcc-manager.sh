set -euo pipefail

die() {
  printf >&2 'tcc-manager: %s\n' "$*"
  exit 1
}

usage() {
  cat >&2 <<'EOF'
usage: tcc-manager (check|apply) --manifest PATH --system-db PATH --user-db PATH --user NAME [options]

options:
  --live-roots PATH       newline-delimited live Nix store roots (required for apply)
  --csr-status-file PATH  use captured csrutil output instead of invoking csrutil
  --no-reload             do not reload the user's tccd after changes
EOF
  exit 2
}

action=${1:-}
[[ "$action" == check || "$action" == apply ]] || usage
shift

manifest=
system_db=
user_db=
target_user=
live_roots=
csr_status_file=
reload_tccd=1

while (($#)); do
  case "$1" in
    --manifest)
      manifest=${2:-}
      shift 2
      ;;
    --system-db)
      system_db=${2:-}
      shift 2
      ;;
    --user-db)
      user_db=${2:-}
      shift 2
      ;;
    --user)
      target_user=${2:-}
      shift 2
      ;;
    --live-roots)
      live_roots=${2:-}
      shift 2
      ;;
    --csr-status-file)
      csr_status_file=${2:-}
      shift 2
      ;;
    --no-reload)
      reload_tccd=0
      shift
      ;;
    *) usage ;;
  esac
done

[[ -f "$manifest" ]] || die "manifest does not exist: $manifest"
[[ -n "$system_db" ]] || die "--system-db is required"
[[ -n "$user_db" ]] || die "--user-db is required"
[[ -n "$target_user" ]] || die "--user is required"
if [[ "$action" == apply ]]; then
  [[ -f "$live_roots" ]] || die "--live-roots is required for apply"
fi

target_uid=$(id -u "$target_user") || die "user does not exist: $target_user"
current_uid=$(id -u)

run_as_user() {
  if [[ "$current_uid" == "$target_uid" ]]; then
    "$@"
  elif [[ "$current_uid" == 0 ]]; then
    /usr/bin/sudo -u "$target_user" -- "$@"
  else
    die "must run as root or $target_user to access the user TCC database"
  fi
}

sqlite_uri() {
  local path=$1
  path=${path//%/%25}
  path=${path// /%20}
  path=${path//#/%23}
  path=${path//\?/%3F}
  printf 'file:%s?mode=rw' "$path"
}

system_db_uri=$(sqlite_uri "$system_db")
user_db_uri=$(sqlite_uri "$user_db")
sqlite_bin=$(command -v sqlite3)

# shellcheck disable=SC2120 # Called with SQL through check_database.
sqlite_system() {
  "$sqlite_bin" "$system_db_uri" "$@"
}

# shellcheck disable=SC2120 # Called with SQL through check_database.
sqlite_user() {
  run_as_user "$sqlite_bin" "$user_db_uri" "$@"
}

sqlite_system_stdin() {
  "$sqlite_bin" "$system_db_uri"
}

sqlite_user_stdin() {
  run_as_user "$sqlite_bin" "$user_db_uri"
}

check_sip() {
  local csr_output
  if [[ -n "$csr_status_file" ]]; then
    [[ -f "$csr_status_file" ]] || die "csrutil status fixture does not exist: $csr_status_file"
    csr_output=$(<"$csr_status_file")
  else
    csr_output=$({ /usr/bin/csrutil status 2>&1 || true; })
  fi

  if ! grep -Eq \
    '^System Integrity Protection status: disabled\.?$|^[[:space:]]*Filesystem Protections:[[:space:]]+disabled$' \
    <<<"$csr_output"; then
    die "wthueb.security.tcc.enable requires SIP filesystem protections to be disabled"
  fi
}

required_columns_sql="
SELECT count(*)
FROM pragma_table_info('access')
WHERE name IN (
  'service', 'client', 'client_type', 'auth_value', 'auth_reason', 'auth_version',
  'csreq', 'policy_id', 'indirect_object_identifier_type',
  'indirect_object_identifier', 'indirect_object_code_identity', 'flags',
  'last_modified', 'pid', 'pid_version', 'boot_uuid', 'last_reminded'
);"

primary_key_sql="
SELECT group_concat(name, ',')
FROM (
  SELECT name
  FROM pragma_table_info('access')
  WHERE pk > 0
  ORDER BY pk
);"

unsupported_required_sql="
SELECT group_concat(name, ',')
FROM pragma_table_info('access')
WHERE \"notnull\" = 1
  AND dflt_value IS NULL
  AND name NOT IN (
    'service', 'client', 'client_type', 'auth_value', 'auth_reason', 'auth_version',
    'csreq', 'policy_id', 'indirect_object_identifier_type',
    'indirect_object_identifier', 'indirect_object_code_identity', 'flags',
    'last_modified', 'pid', 'pid_version', 'boot_uuid', 'last_reminded'
  );"

check_database() {
  local scope=$1
  local path=$2
  local query=$3
  local columns primary_key unsupported quick_check

  [[ -f "$path" ]] || die "$scope TCC database does not exist: $path"
  "$query" 'PRAGMA busy_timeout=10000; BEGIN IMMEDIATE; UPDATE access SET auth_value = auth_value WHERE 0; ROLLBACK;' >/dev/null \
    || die "$scope TCC database cannot complete a rolled-back write transaction: $path"

  columns=$("$query" "$required_columns_sql") \
    || die "could not inspect the $scope TCC schema"
  [[ "$columns" == 17 ]] \
    || die "$scope TCC access table does not contain the required columns"

  primary_key=$("$query" "$primary_key_sql") \
    || die "could not inspect the $scope TCC primary key"
  [[ "$primary_key" == 'service,client,client_type,indirect_object_identifier' ]] \
    || die "$scope TCC access table has an unsupported primary key: $primary_key"

  unsupported=$("$query" "$unsupported_required_sql") \
    || die "could not inspect required columns in the $scope TCC database"
  [[ -z "$unsupported" ]] \
    || die "$scope TCC access table has unsupported required columns: $unsupported"

  quick_check=$("$query" 'PRAGMA quick_check;') \
    || die "$scope TCC database failed PRAGMA quick_check"
  [[ "$quick_check" == ok ]] || die "$scope TCC database is not healthy: $quick_check"
}

validate_manifest() {
  jq -e '
    type == "array" and
    all(.[];
      (.scope == "system" or .scope == "user") and
      (.service | type == "string") and
      (.client | type == "string") and
      (.authReason | type == "number") and
      ((.flags == null) or (.flags | type == "number")) and
      ((.indirectType == null) or (.indirectType | type == "number")) and
      ((.indirectObject == null) or
        ((.indirectObject.identifier | type == "string") and
         (.indirectObject.path | type == "string"))) and
      (if .service == "kTCCServiceAppleEvents"
       then .indirectObject != null
       else .indirectObject == null
       end)
    )
  ' "$manifest" >/dev/null || die "manifest has an invalid shape"
}

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/nix-tcc.XXXXXX")
trap 'rm -rf -- "$tmp_dir"' EXIT
prepared_ndjson="$tmp_dir/prepared.ndjson"
prepared_manifest="$tmp_dir/prepared.json"
normalized_roots="$tmp_dir/live-roots"
: >"$prepared_ndjson"

normalize_live_roots() {
  local root
  : >"$normalized_roots"
  while IFS= read -r root; do
    [[ -z "$root" ]] && continue
    [[ "$root" =~ ^/nix/store/[^/]+$ ]] || die "invalid live Nix store root: $root"
    printf '%s\n' "$root" >>"$normalized_roots"
  done <"$live_roots"
  sort -u -o "$normalized_roots" "$normalized_roots"
}

code_requirement_hex() {
  local executable=$1
  local output=$2
  local requirement

  requirement=$(/usr/bin/codesign -d -r- "$executable" 2>&1 | sed -n 's/^.*designated => //p')
  [[ -n "$requirement" ]] || die "could not derive a code requirement for $executable"
  /usr/bin/csreq -r="$requirement" -b "$output" \
    || die "could not compile the code requirement for $executable"
  /usr/bin/xxd -p "$output" | tr -d '\n' | tr '[:lower:]' '[:upper:]'
}

prepare_manifest() {
  local entry client canonical_client store_root csreq_hex
  local indirect_path indirect_canonical indirect_hex record index=0

  while IFS= read -r entry; do
    client=$(jq -r '.client' <<<"$entry")
    canonical_client=$(realpath -e -- "$client") \
      || die "configured TCC client does not exist: $client"
    [[ -f "$canonical_client" && -x "$canonical_client" ]] \
      || die "configured TCC client is not an executable file: $canonical_client"
    [[ "$canonical_client" =~ ^(/nix/store/[^/]+)(/.*)?$ ]] \
      || die "refusing to manage a non-Nix TCC client: $canonical_client"
    store_root=${BASH_REMATCH[1]}

    if [[ "$action" == apply ]] && ! grep -Fxq -- "$store_root" "$normalized_roots"; then
      die "configured TCC client is absent from the new system closure: $canonical_client"
    fi

    csreq_hex=$(code_requirement_hex "$canonical_client" "$tmp_dir/client-$index.csreq")
    indirect_hex=

    if [[ $(jq -r '.indirectObject == null' <<<"$entry") == false ]]; then
      indirect_path=$(jq -r '.indirectObject.path' <<<"$entry")
      indirect_canonical=$(realpath -e -- "$indirect_path") \
        || die "Apple Events target does not exist: $indirect_path"
      indirect_hex=$(code_requirement_hex "$indirect_canonical" "$tmp_dir/indirect-$index.csreq")
    fi

    record=$(jq -cn \
      --argjson entry "$entry" \
      --arg client "$canonical_client" \
      --arg csreqHex "$csreq_hex" \
      --arg indirectCsreqHex "$indirect_hex" \
      '$entry + {
        client: $client,
        csreqHex: $csreqHex,
        indirectCsreqHex: (if $indirectCsreqHex == "" then null else $indirectCsreqHex end)
      }')
    printf '%s\n' "$record" >>"$prepared_ndjson"
    index=$((index + 1))
  done < <(jq -c '.[]' "$manifest")

  jq -s . "$prepared_ndjson" >"$prepared_manifest"
}

sql_text() {
  local value=$1 hex
  hex=$(printf '%s' "$value" | /usr/bin/xxd -p | tr -d '\n' | tr '[:lower:]' '[:upper:]')
  printf "CAST(X'%s' AS TEXT)" "$hex"
}

write_reconcile_sql() {
  local scope=$1 output=$2 root entry service client auth_reason flags
  local indirect_type indirect_identifier indirect_hex csreq_hex

  {
    printf '.timeout 10000\n'
    printf 'PRAGMA foreign_keys=ON;\n'
    printf 'BEGIN IMMEDIATE;\n'
    printf 'CREATE TEMP TABLE live_nix_store_roots (root TEXT PRIMARY KEY);\n'
    while IFS= read -r root; do
      printf 'INSERT INTO live_nix_store_roots(root) VALUES (%s);\n' "$(sql_text "$root")"
    done <"$normalized_roots"
    printf 'CREATE TEMP TABLE change_baseline (n INTEGER NOT NULL);\n'
    printf 'INSERT INTO change_baseline(n) VALUES (total_changes() + 1);\n'
    printf '%s\n' \
      "DELETE FROM access" \
      "WHERE client GLOB '/nix/store/*'" \
      "  AND NOT EXISTS (" \
      "    SELECT 1 FROM live_nix_store_roots" \
      "    WHERE access.client = root" \
      "       OR substr(access.client, 1, length(root) + 1) = root || '/'" \
      "  );"

    while IFS= read -r entry; do
      service=$(jq -r '.service' <<<"$entry")
      client=$(jq -r '.client' <<<"$entry")
      auth_reason=$(jq -r '.authReason' <<<"$entry")
      flags=$(jq -r '.flags' <<<"$entry")
      indirect_type=$(jq -r '.indirectType' <<<"$entry")
      csreq_hex=$(jq -r '.csreqHex' <<<"$entry")

      if [[ $(jq -r '.indirectObject == null' <<<"$entry") == true ]]; then
        indirect_identifier=UNUSED
        indirect_hex=null
      else
        indirect_identifier=$(jq -r '.indirectObject.identifier' <<<"$entry")
        indirect_hex=$(jq -r '.indirectCsreqHex' <<<"$entry")
      fi

      [[ "$flags" == null ]] && flags=NULL
      [[ "$indirect_type" == null ]] && indirect_type=NULL

      printf '%s\n' \
        "INSERT INTO access (" \
        "  service, client, client_type, auth_value, auth_reason, auth_version," \
        "  csreq, policy_id, indirect_object_identifier_type," \
        "  indirect_object_identifier, indirect_object_code_identity, flags," \
        "  last_modified, pid, pid_version, boot_uuid, last_reminded" \
        ") VALUES (" \
        "  $(sql_text "$service"), $(sql_text "$client"), 1, 2, $auth_reason, 1," \
        "  X'$csreq_hex', NULL, $indirect_type," \
        "  $(sql_text "$indirect_identifier"), $([[ "$indirect_hex" == null ]] && printf NULL || printf "X'%s'" "$indirect_hex"), $flags," \
        "  CAST(strftime('%s', 'now') AS INTEGER), NULL, NULL, 'UNUSED', 0" \
        ")" \
        "ON CONFLICT(service, client, client_type, indirect_object_identifier) DO UPDATE SET" \
        "  auth_value = excluded.auth_value," \
        "  auth_reason = excluded.auth_reason," \
        "  auth_version = excluded.auth_version," \
        "  csreq = excluded.csreq," \
        "  policy_id = excluded.policy_id," \
        "  indirect_object_identifier_type = excluded.indirect_object_identifier_type," \
        "  indirect_object_code_identity = excluded.indirect_object_code_identity," \
        "  flags = excluded.flags," \
        "  last_modified = CAST(strftime('%s', 'now') AS INTEGER)," \
        "  pid = excluded.pid," \
        "  pid_version = excluded.pid_version," \
        "  boot_uuid = excluded.boot_uuid," \
        "  last_reminded = excluded.last_reminded" \
        "WHERE access.auth_value IS NOT excluded.auth_value" \
        "   OR access.auth_reason IS NOT excluded.auth_reason" \
        "   OR access.auth_version IS NOT excluded.auth_version" \
        "   OR access.csreq IS NOT excluded.csreq" \
        "   OR access.policy_id IS NOT excluded.policy_id" \
        "   OR access.indirect_object_identifier_type IS NOT excluded.indirect_object_identifier_type" \
        "   OR access.indirect_object_code_identity IS NOT excluded.indirect_object_code_identity" \
        "   OR access.flags IS NOT excluded.flags" \
        "   OR access.pid IS NOT excluded.pid" \
        "   OR access.pid_version IS NOT excluded.pid_version" \
        "   OR access.boot_uuid IS NOT excluded.boot_uuid" \
        "   OR access.last_reminded IS NOT excluded.last_reminded;"
    done < <(jq -c --arg scope "$scope" '.[] | select(.scope == $scope)' "$prepared_manifest")

    printf 'SELECT total_changes() - (SELECT n FROM change_baseline);\n'
    printf 'COMMIT;\n'
  } >"$output"
}

check_sip
validate_manifest
check_database system "$system_db" sqlite_system
check_database user "$user_db" sqlite_user

if [[ "$action" == apply ]]; then
  normalize_live_roots
fi
prepare_manifest

if [[ "$action" == check ]]; then
  printf 'TCC preflight passed\n'
  exit 0
fi

system_sql="$tmp_dir/system.sql"
user_sql="$tmp_dir/user.sql"
write_reconcile_sql system "$system_sql"
write_reconcile_sql user "$user_sql"

system_changes=$(sqlite_system_stdin <"$system_sql") \
  || die "failed to reconcile the system TCC database"
user_changes=$(sqlite_user_stdin <"$user_sql") \
  || die "failed to reconcile the user TCC database"
[[ "$system_changes" =~ ^[0-9]+$ ]] || die "invalid system database change count: $system_changes"
[[ "$user_changes" =~ ^[0-9]+$ ]] || die "invalid user database change count: $user_changes"
total_changes=$((system_changes + user_changes))

check_database system "$system_db" sqlite_system
check_database user "$user_db" sqlite_user

printf 'TCC reconciliation changed %d row(s)\n' "$total_changes"

if ((total_changes > 0 && reload_tccd)); then
  service="gui/$target_uid/com.apple.tccd"
  if /bin/launchctl print "$service" >/dev/null 2>&1; then
    /bin/launchctl kickstart -k "$service" \
      || printf >&2 'tcc-manager: warning: could not reload %s\n' "$service"
  fi
fi
