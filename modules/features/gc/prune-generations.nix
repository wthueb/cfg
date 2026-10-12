{
  lib,
  nixEnv,
  olderThan,
  profiles,
}:
''
  set -euo pipefail
  for profile in ${lib.escapeShellArgs profiles}; do
    if [[ -e "$profile" ]]; then
      ${lib.escapeShellArg nixEnv} --profile "$profile" --delete-generations ${lib.escapeShellArg olderThan}
    fi
  done
''
