{
  lib,
  runCommand,
  writeShellScript,
  nix,
}:
let
  prune =
    nixEnv: profiles:
    writeShellScript "test-generation-pruning" (
      import ./prune-generations.nix {
        inherit lib nixEnv profiles;
        olderThan = "14d";
      }
    );
  mockNixEnv = writeShellScript "mock-nix-env" ''
    set -euo pipefail
    printf '%s\n' "$@" >> "$calls"
    exit "''${FAIL_CODE:-0}"
  '';
  mockPrune = prune "${mockNixEnv}" [
    "profiles/system"
    "profiles/home manager"
    "profiles/missing"
  ];
  missingPrune = prune "${mockNixEnv}" [ "profiles/missing" ];
  realPrune = prune "${nix}/bin/nix-env" [ "profiles/real" ];
in
runCommand "gc-generation-pruning-test" { } ''
  mkdir -p profiles target
  touch profiles/system "profiles/home manager"
  export calls="$PWD/calls"
  ${mockPrune}
  printf '%s\n' \
    --profile profiles/system --delete-generations 14d \
    --profile "profiles/home manager" --delete-generations 14d > expected
  cmp calls expected

  rm calls
  ${missingPrune}
  test ! -e calls

  if FAIL_CODE=42 ${mockPrune}; then
    echo "Pruning did not propagate a failure" >&2
    exit 1
  else
    test "$?" -eq 42
  fi

  for generation in 1 2 3 4; do
    ln -s "$PWD/target" "profiles/real-$generation-link"
  done
  touch -h -t 200001010000 profiles/real-1-link
  touch -h -t 200001020000 profiles/real-2-link
  touch -h -t 200001030000 profiles/real-3-link
  ln -s real-1-link profiles/real

  ${realPrune}
  test -L profiles/real-1-link
  test ! -L profiles/real-2-link
  test -L profiles/real-3-link
  test -L profiles/real-4-link
  test "$(readlink profiles/real)" = real-1-link
  test -d target

  touch "$out"
''
