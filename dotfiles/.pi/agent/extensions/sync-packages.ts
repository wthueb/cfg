import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

type PackageEntry = string | { source: string; [key: string]: unknown };
type Settings = Record<string, unknown> & { packages?: PackageEntry[] };
type Manifest = { packages: string[] };

const agentDir = getAgentDir();
const manifestPath = join(agentDir, "packages.json");
const settingsPath = join(agentDir, "settings.json");

function sourceOf(entry: PackageEntry): string {
  return typeof entry === "string" ? entry : entry.source;
}

function parseManifest(content: string): Manifest {
  const manifest = JSON.parse(content) as Partial<Manifest>;

  if (
    !Array.isArray(manifest.packages) ||
    manifest.packages.some((entry) => typeof entry !== "string" || !entry.trim())
  ) {
    throw new Error("packages.json must contain a packages array of non-empty strings");
  }

  return { packages: [...new Set(manifest.packages)] };
}

function parseSettings(content: string): Settings {
  const settings = JSON.parse(content) as Settings;

  if (
    settings.packages !== undefined &&
    (!Array.isArray(settings.packages) ||
      settings.packages.some(
        (entry) =>
          typeof entry !== "string" &&
          (typeof entry !== "object" ||
            entry === null ||
            typeof entry.source !== "string"),
      ))
  ) {
    throw new Error("settings.json contains an invalid packages value");
  }

  return settings;
}

async function readConfiguration(): Promise<{
  settings: Settings;
  additions: string[];
}> {
  const manifest = parseManifest(await readFile(manifestPath, "utf8"));
  const settings = parseSettings(await readFile(settingsPath, "utf8"));
  const existing = new Set((settings.packages ?? []).map(sourceOf));
  const additions = manifest.packages.filter((source) => !existing.has(source));

  return { settings, additions };
}

async function addMissingPackages(): Promise<string[]> {
  const { settings, additions } = await readConfiguration();
  if (additions.length === 0) return [];

  settings.packages = [...(settings.packages ?? []), ...additions];
  await writeFile(settingsPath, `${JSON.stringify(settings, null, 2)}\n`, "utf8");

  return additions;
}

export default function (pi: ExtensionAPI) {
  let syncQueued = false;
  let syncRunning = false;

  pi.registerCommand("sync-packages", {
    description: "Add packages from the shared package manifest",
    handler: async (_args, ctx) => {
      if (syncRunning) return;
      syncRunning = true;

      let additions: string[];

      try {
        additions = await addMissingPackages();
      } catch (error) {
        syncRunning = false;
        ctx.ui.notify(
          `Could not synchronize shared packages: ${error instanceof Error ? error.message : String(error)}`,
          "error",
        );
        return;
      }

      if (additions.length === 0) {
        syncRunning = false;
        ctx.ui.notify("Shared packages are already configured", "info");
        return;
      }

      ctx.ui.notify(`Added ${additions.length} shared package(s)`, "info");
      await ctx.reload();
      return;
    },
  });

  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "startup" || syncQueued) return;

    try {
      const { additions } = await readConfiguration();
      if (additions.length === 0) return;

      syncQueued = true;
      ctx.ui.notify(
        `Adding ${additions.length} package(s) from the shared manifest`,
        "info",
      );
      pi.sendUserMessage("/sync-packages", { expandPromptTemplates: true });
    } catch (error) {
      ctx.ui.notify(
        `Could not read the shared package manifest: ${error instanceof Error ? error.message : String(error)}`,
        "error",
      );
    }
  });
}
