import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";

const PLAN_MODE_QUESTION_TOOL = "plan_mode_question";
const PLAN_MODE_COMPLETE_TOOL = "plan_mode_complete";

const TITLE = "pi";

const APPLE_SCRIPT = `
on run argv
  display notification (item 2 of argv) with title (item 1 of argv) sound name "Submarine"
end run
`;

const WINDOWS_SCRIPT = `
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$textNodes = $template.GetElementsByTagName("text")
[void]$textNodes.Item(0).AppendChild($template.CreateTextNode($env:PI_NOTIFICATION_TITLE))
[void]$textNodes.Item(1).AppendChild($template.CreateTextNode($env:PI_NOTIFICATION_BODY))
$toast = [Windows.UI.Notifications.ToastNotification]::new($template)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($env:PI_NOTIFICATION_TITLE).Show($toast)
`;

function notify(body: string): Promise<void> {
  return new Promise((resolve) => {
    const done = () => resolve();

    if (process.platform === "darwin") {
      execFile("/usr/bin/osascript", ["-e", APPLE_SCRIPT, "--", TITLE, body], done);
      return;
    }

    if (
      process.platform === "win32" ||
      process.env.WSL_DISTRO_NAME ||
      process.env.WSL_INTEROP
    ) {
      execFile(
        "powershell.exe",
        ["-NoLogo", "-NoProfile", "-NonInteractive", "-Command", WINDOWS_SCRIPT],
        {
          env: {
            ...process.env,
            PI_NOTIFICATION_TITLE: TITLE,
            PI_NOTIFICATION_BODY: body,
          },
          windowsHide: true,
        },
        done,
      );
      return;
    }

    if (process.platform === "linux") {
      execFile("notify-send", ["--app-name", TITLE, "--", TITLE, body], done);
      return;
    }

    resolve();
  });
}

export default function (pi: ExtensionAPI) {
  let planModeCompletionPending = false;

  pi.on("tool_execution_start", async (event, ctx) => {
    if (ctx.mode !== "tui" || event.toolName !== PLAN_MODE_QUESTION_TOOL) return;
    await notify("plan mode question");
  });

  pi.on("tool_execution_end", async (event, ctx) => {
    if (
      ctx.mode !== "tui" ||
      event.toolName !== PLAN_MODE_COMPLETE_TOOL ||
      event.isError
    ) {
      return;
    }
    planModeCompletionPending = true;
    await notify("plan complete");
  });

  pi.on("agent_settled", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    if (planModeCompletionPending) {
      planModeCompletionPending = false;
      return;
    }
    await notify("waiting for input");
  });
}
