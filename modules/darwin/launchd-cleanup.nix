{ config, lib, ... }:
let
  primaryUser = lib.escapeShellArg config.system.primaryUser;
  newLaunchd = config.system.build.launchd;
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    reconcileRemovedLaunchdJobs() {
      local oldDir="$1"
      local newDir="$2"
      local domain="$3"
      local oldPlist filename label target

      [[ -d "$oldDir" ]] || return 0

      for oldPlist in "$oldDir"/*.plist; do
        [[ -e "$oldPlist" ]] || continue
        filename="''${oldPlist##*/}"
        [[ ! -e "$newDir/$filename" ]] || continue

        if ! label=$(/usr/bin/plutil -extract Label raw "$oldPlist" 2>/dev/null); then
          echo "error: cannot read Label from removed launchd job $oldPlist" >&2
          return 1
        fi

        target="$domain/$label"
        if /bin/launchctl print "$target" >/dev/null 2>&1; then
          echo "booting out removed launchd job $target" >&2
          /bin/launchctl bootout "$target" >/dev/null 2>&1 || true

          if /bin/launchctl print "$target" >/dev/null 2>&1; then
            echo "error: removed launchd job remains loaded: $target" >&2
            return 1
          fi
        fi
      done
    }

    primaryUserUid=$(/usr/bin/id -u -- ${primaryUser})

    reconcileRemovedLaunchdJobs \
      /run/current-system/Library/LaunchDaemons \
      ${newLaunchd}/Library/LaunchDaemons \
      system

    reconcileRemovedLaunchdJobs \
      /run/current-system/Library/LaunchAgents \
      ${newLaunchd}/Library/LaunchAgents \
      "gui/$primaryUserUid"

    # Older nix-darwin releases could load /Library/LaunchAgents into the
    # system domain because they used launchctl's legacy context inference.
    reconcileRemovedLaunchdJobs \
      /run/current-system/Library/LaunchAgents \
      ${newLaunchd}/Library/LaunchAgents \
      system

    reconcileRemovedLaunchdJobs \
      /run/current-system/user/Library/LaunchAgents \
      ${newLaunchd}/user/Library/LaunchAgents \
      "gui/$primaryUserUid"
  '';
}
