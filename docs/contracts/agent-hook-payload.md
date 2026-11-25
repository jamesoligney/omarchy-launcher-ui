# Contract: agent hook payload (v1)

**Status:** frozen in Stage 0 of the bar restructure (2026-11-25). **Contract only; nothing implements it yet.** The schema is `agent-hook-payload.schema.json` next to this file.

## Purpose

Mission control should show what agents are doing **now** without polling. Agents push it themselves through their hook systems. For example, Claude Code hooks run a command on session start, prompt submit, tool use, notification and stop. Each event becomes one JSON payload.

## Shape

One JSON object per event. Required: `v`, `agent.id`, `session.id`, `event`, `state`, `at`.

```json
{
  "v": 1,
  "agent":   { "id": "claude", "name": "Claude Code" },
  "session": { "id": "8f1c…", "cwd": "/home/jimmy/orca/projects/omarchy-launcher-ui", "pid": 4242, "window": "0x55d1c0a8b2f0" },
  "event":   "waiting",
  "state":   "waiting",
  "at":      "2026-11-25T08:40:12-08:00",
  "message": "Permission needed: Bash",
  "model":   "claude-sonnet-5-5"
}
```

| Field | Meaning |
|---|---|
| `event` | `session_start`, `prompt`, `working`, `tool`, `waiting`, `done`, `error`, `session_end` |
| `state` | `idle`, `working`, `waiting` (needs the user: drives the amber dot), `error`, `ended` |
| `agent.id` | Same id as the usage record in `~/.local/state/omarchy/agents/usage/<id>.json`, so live status and usage join on one key |
| `session.window` | Hyprland window address, so a click or key in mission control can focus the agent's window |
| `tokens` | Optional per-turn counts. **Limits never come from hooks**; they stay in the usage records |

## Rules the future receiver must follow

- **Transport (planned, not built):** the hook runs one command, e.g. `omarchy-shell jimmy.agents event '<json>'`, a fire-and-forget IPC call. It must return in well under 100 ms and never block the agent.
- **Validation:** unknown `v`, missing required fields or oversize strings are dropped silently; one bad hook never breaks the bar.
- **Privacy:** `message` is a short label (tool name, question summary). Never prompt text, file contents or secrets. `cwd` is shown as a folder name only.
- **Liveness:** a session with no event for a timeout, or whose `pid` is gone, is treated as ended. That check is event-driven where possible (`session_end`, Hyprland window close) and a coarse fallback otherwise.
- **Persistence:** none. Live status is in memory only and is not runtime state worth backing up.
- **Versioning:** additive optional fields keep `v: 1`; anything breaking is `v: 2`, and the receiver may support both.
