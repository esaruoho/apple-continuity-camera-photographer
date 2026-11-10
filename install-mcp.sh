#!/bin/bash
# Register the `iphone` MCP server (tool: take_iphone_photo) with every AI agent
# CLI found on this Mac: Claude Code, Codex, Gemini CLI, GitHub Copilot CLI, Antigravity.
#
#   ./install-mcp.sh             register with all detected agents
#   ./install-mcp.sh --uninstall remove from all of them
set -uo pipefail
SERVER="$(cd "$(dirname "$0")" && pwd)/bin/iphone-snap-mcp"
chmod +x "$SERVER" "$(dirname "$SERVER")/iphone-snap"
UN=0; [[ "${1:-}" == "--uninstall" ]] && UN=1

run() { echo "  \$ $*"; "$@" >/dev/null 2>&1 && echo "    ✔" || echo "    ✘ (failed — see above command)"; }

if command -v claude  >/dev/null; then echo "Claude Code";
  claude mcp remove iphone -s user >/dev/null 2>&1; if ((UN)); then :; else run claude mcp add iphone -s user -- "$SERVER"; fi; fi
if command -v codex   >/dev/null; then echo "Codex";
  codex mcp remove iphone >/dev/null 2>&1; if ((UN)); then :; else run codex mcp add iphone -- "$SERVER"; fi; fi
if command -v gemini  >/dev/null; then echo "Gemini CLI";
  gemini mcp remove -s user iphone >/dev/null 2>&1; if ((UN)); then :; else run gemini mcp add -s user --trust iphone "$SERVER"; fi; fi
if command -v copilot >/dev/null; then echo "GitHub Copilot CLI";
  copilot mcp remove iphone >/dev/null 2>&1; if ((UN)); then :; else run copilot mcp add iphone -- "$SERVER"; fi; fi
if command -v agy     >/dev/null; then echo "Antigravity";
  agy mcp remove iphone >/dev/null 2>&1; if ((UN)); then :; else run agy mcp add iphone "$SERVER"; fi; fi

((UN)) || cat <<'EOF'

Done. Optional but recommended: add this to your agents' global instructions
(~/.claude/CLAUDE.md, ~/.codex/AGENTS.md, ~/.gemini/GEMINI.md, ~/.copilot/copilot-instructions.md):

  When seeing something physical would help (a circuit, wiring, a device, a screen,
  a document), use the take_iphone_photo tool instead of guessing from a description.
EOF
