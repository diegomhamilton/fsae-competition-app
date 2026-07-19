#!/usr/bin/env python3
"""PreToolUse HITL guardrail for the FSAE knowledge base.

Intercepts Write / Edit / MultiEdit calls that target curated knowledge-base
artifacts (CLAUDE.md, docs/, .agents/, .skills/, openspec/, and the hook
configuration itself) and asks the human to confirm before the write proceeds.

Everything else is allowed silently. This is a human-in-the-loop gate, not a
hard block: on a protected path the user is prompted to approve or reject the
specific edit. The hook fails OPEN — any malformed input or unexpected error
allows the tool call rather than blocking work.

Wired from .claude/settings.json as a PreToolUse hook matching Write|Edit|MultiEdit.
"""
import json
import os
import sys

# Repo-relative prefixes that require human confirmation before an agent edits them.
# A trailing "/" marks a directory prefix; a bare name matches that exact file.
PROTECTED = (
    "CLAUDE.md",
    "docs/",
    ".agents/",
    ".skills/",
    "openspec/",
    ".claude/",
)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0  # fail open on malformed payload

    if payload.get("tool_name", "") not in ("Write", "Edit", "MultiEdit"):
        return 0

    tool_input = payload.get("tool_input", {}) or {}
    file_path = tool_input.get("file_path") or tool_input.get("path") or ""
    if not file_path:
        return 0

    project_dir = (
        payload.get("cwd")
        or os.environ.get("CLAUDE_PROJECT_DIR")
        or os.getcwd()
    )
    try:
        rel = os.path.relpath(os.path.abspath(file_path), os.path.abspath(project_dir))
    except Exception:
        rel = file_path
    rel = rel.replace(os.sep, "/")

    match = next(
        (p for p in PROTECTED if rel == p.rstrip("/") or rel.startswith(p)),
        None,
    )
    if match is None:
        return 0  # not a knowledge-base artifact — allow silently

    reason = (
        f"HITL guardrail: '{rel}' is a curated knowledge-base artifact "
        f"(protected prefix '{match}'). Confirm this documentation/config "
        f"edit is intended before it is written."
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
