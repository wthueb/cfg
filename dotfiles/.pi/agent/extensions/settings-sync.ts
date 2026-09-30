import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { isDeepStrictEqual } from "node:util";

type PackageEntry = string | { source: string; [key: string]: unknown };
type Settings = Record<string, unknown> & { packages?: PackageEntry[] };

const agentDir = getAgentDir();
const manifestPath = join(agentDir, "settings-sync.json");
const settingsPath = join(agentDir, "settings.json");

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function sourceOf(entry: PackageEntry): string {
  return typeof entry === "string" ? entry : entry.source;
}

function parseSettings(content: string, filename: string): Settings {
  const settings: unknown = JSON.parse(content);

  if (!isObject(settings)) {
    throw new Error(`${filename} must contain a JSON object`);
  }

  if (
    settings.packages !== undefined &&
    (!Array.isArray(settings.packages) ||
      settings.packages.some((entry: unknown) => {
        const source =
          typeof entry === "string" ? entry : isObject(entry) ? entry.source : undefined;
        return typeof source !== "string" || !source.trim();
      }))
  ) {
    throw new Error(`${filename} contains an invalid packages value`);
  }

  return settings as Settings;
}

function mergeObjects(
  settings: Record<string, unknown>,
  shared: Record<string, unknown>,
): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries({ ...settings, ...shared }).map(([key, value]) => [
      key,
      isObject(settings[key]) && isObject(shared[key])
        ? mergeObjects(settings[key], shared[key])
        : value,
    ]),
  );
}

function mergeSettings(settings: Settings, shared: Settings): Settings {
  const merged = mergeObjects(settings, shared) as Settings;

  if (shared.packages !== undefined) {
    const packages = [...(settings.packages ?? [])];
    const existing = new Set(packages.map(sourceOf));

    for (const entry of shared.packages) {
      const source = sourceOf(entry);
      if (existing.has(source)) continue;
      packages.push(entry);
      existing.add(source);
    }

    merged.packages = packages;
  }

  return merged;
}

async function readConfiguration(): Promise<{
  settings: Settings;
  changes: string[];
}> {
  const shared = parseSettings(await readFile(manifestPath, "utf8"), "settings-sync.json");
  let localContent: string;

  try {
    localContent = await readFile(settingsPath, "utf8");
  } catch (error) {
    if (!isObject(error) || error.code !== "ENOENT") throw error;
    localContent = "{}";
  }

  const local = parseSettings(localContent, "settings.json");
  const settings = mergeSettings(local, shared);
  const changes = Object.keys(shared).filter(
    (key) => !isDeepStrictEqual(local[key], settings[key]),
  );

  return { settings, changes };
}

async function synchronizeSettings(): Promise<string[]> {
  const { settings, changes } = await readConfiguration();
  if (changes.length === 0) return [];

  await writeFile(settingsPath, `${JSON.stringify(settings, null, 2)}\n`, "utf8");
  return changes;
}

export default function (pi: ExtensionAPI) {
  let syncQueued = false;
  let syncRunning = false;

  const command = {
    description: "Merge shared settings from settings-sync.json",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      if (syncRunning) return;
      syncRunning = true;

      let changes: string[];

      try {
        changes = await synchronizeSettings();
      } catch (error) {
        syncRunning = false;
        ctx.ui.notify(
          `Could not synchronize shared settings: ${error instanceof Error ? error.message : String(error)}`,
          "error",
        );
        return;
      }

      if (changes.length === 0) {
        syncRunning = false;
        ctx.ui.notify("Shared settings are already configured", "info");
        return;
      }

      ctx.ui.notify(`Synchronized shared settings: ${changes.join(", ")}`, "info");
      if (changes.includes("tuiMode")) {
        ctx.ui.notify("Restart Pi to apply the new tuiMode", "info");
      }

      try {
        await ctx.reload();
      } catch (error) {
        syncRunning = false;
        ctx.ui.notify(
          `Settings were synchronized, but reload failed: ${error instanceof Error ? error.message : String(error)}`,
          "error",
        );
      }
    },
  };

  pi.registerCommand("settings-sync", command);

  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "startup" || syncQueued) return;

    try {
      const { changes } = await readConfiguration();
      if (changes.length === 0) return;

      syncQueued = true;
      ctx.ui.notify(`Synchronizing shared settings: ${changes.join(", ")}`, "info");
      pi.sendUserMessage("/settings-sync", { expandPromptTemplates: true });
    } catch (error) {
      ctx.ui.notify(
        `Could not read shared settings: ${error instanceof Error ? error.message : String(error)}`,
        "error",
      );
    }
  });
}
