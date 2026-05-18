# AI Agent Extensions (MCP & Skills)

Recommended tools for Claude Code and Gemini CLI to enhance research, coding, and workflow automation.

## MCP Servers (Tooling)
Enable these in `~/.claude/config.json` or `~/.gemini/settings.json`.

| Server | Use Case | Implementation |
| :--- | :--- | :--- |
| **Sequential Thinking** | Reasoning | Break complex tasks into logical steps. (Built-in for Claude). |
| **Memory Bank** | Context | Persistent knowledge graph/store for project facts and preferences. |
| **GitHub** | Repo Mgmt | Manage PRs, issues, and search code across your organization. |
| **Firecrawl** | Docs Ingestion | Convert any URL/documentation to clean Markdown for the agent. |
| **Brave/Tavily Search** | Research | Clean, AI-optimized web search (better than raw Google). |
| **Playwright** | Browser | Let the agent test web UI or scrape dynamic sites. |
| **PostgreSQL** | Database | Natural language queries to inspect schemas and data. |

## Recommended Skills (Expertise)
Add these as `SKILL.md` files in `~/.claude/skills/` or `~/.gemini/skills/`.

| Skill | Description |
| :--- | :--- |
| **Caveman** | (Active) Ultra-compressed communication to save tokens. |
| **Cellar** | (Active) Inspect JVM/Maven dependency APIs and signatures. |
| **Project Memory** | A scratchpad for project-specific rules, patterns, and TODOs. |
| **Reviewer** | Specialized prompts for PR reviews focusing on security and style. |
| **Nix Expert** | Local patterns for Flakes, Home Manager, and NixOS module structure. |

## Nix Configuration Example
Add this to `agents.nix` to keep servers portable:

```nix
home.file.".gemini/settings.json".text = builtins.toJSON {
  mcpServers = {
    github = {
      command = "npx";
      args = [ "-y", "@modelcontextprotocol/server-github" ];
      env = { GITHUB_PERSONAL_ACCESS_TOKEN = "config.lib.file.mkOutOfStoreSymlink /path/to/token"; };
    };
  };
};
```
