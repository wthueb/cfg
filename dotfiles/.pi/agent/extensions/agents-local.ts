import { readFile } from "node:fs/promises";
import { join } from "node:path";
import {
  getAgentDir,
  type BuildSystemPromptOptions,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

const agentDir = getAgentDir();
const globalAgentsPath = join(agentDir, "AGENTS.md");
const localAgentsPath = join(agentDir, "AGENTS.local.md");

function insertAfterGlobalAgents(
  systemPrompt: string,
  options: BuildSystemPromptOptions,
  localBlock: string,
): string {
  const globalAgents = options.contextFiles?.find(
    (file) => file.path === globalAgentsPath,
  );

  if (!globalAgents) return `${systemPrompt}\n\n${localBlock}`;

  const globalBlock = `<project_instructions path="${globalAgents.path}">\n${globalAgents.content}\n</project_instructions>`;
  const index = systemPrompt.indexOf(globalBlock);

  if (index === -1) return `${systemPrompt}\n\n${localBlock}`;

  const insertionPoint = index + globalBlock.length;
  return `${systemPrompt.slice(0, insertionPoint)}\n\n${localBlock}${systemPrompt.slice(insertionPoint)}`;
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event) => {
    let content: string;

    try {
      content = await readFile(localAgentsPath, "utf8");
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === "ENOENT") return;
      throw error;
    }

    const instructions = content.trim();
    if (!instructions) return;

    const localBlock = `<project_instructions path="${localAgentsPath}">\n${instructions}\n</project_instructions>`;

    return {
      systemPrompt: insertAfterGlobalAgents(
        event.systemPrompt,
        event.systemPromptOptions,
        localBlock,
      ),
    };
  });
}
