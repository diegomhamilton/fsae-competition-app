---
title: Documentation maintenance
domain: inspection-event
status: active
owners: [Documenter, Planner]
source_files: [docs/README.md, CLAUDE.md, .agents/documenter.md]
related_scenarios: [Maintain inspection behavior documentation, Preserve active work]
---

# Documentation maintenance

## Policy

Keep documentation about current behavior, reusable workflows, known unresolved issues and unfinished requirements. Update it in the same PR as the behavior it describes. Delete superseded plans and completed task output rather than adding historical disclaimers or archive folders. Git and pull requests provide change history.

Use the system map as the detailed routing/state/service reference; UI behavior describes judge decisions without duplicating implementation inventories. Keep the index short and remove dead links when deleting or moving a page. Current source-qualified validation may remain, but replace stale results instead of stacking run histories. A passing build, screenshot fixture or closed issue never completes an unverified manual check.

## Ownership

Documenter maintains the index, system map, UI behavior, known issues and tutorials. Tester maintains validation scope and source-qualified results. Planner maintains unfinished OpenSpec tasks and reusable prompts. Feature authors update these surfaces with their changes; review must compare documentation to source.

Reusable prompt templates remain; completed prompt runs do not. Keep unresolved requirements in OpenSpec tasks/specs, including reset/history, disabled team switching, rechecks, stickers and improvements 11–15. Requirements documents must distinguish implemented and deferred behavior.

## Repository cleanup boundaries

Worktree registration is not a reason to retain a redundant checkout. Before removal, inspect current status, unique/squash-equivalent changes, needed ignored files and chat ownership; preserve unfinished work first. Worktree/branch removal remains a separate approved operation from documentation maintenance.

Repository `.agents/`, `.skills/` and generated `.codex/skills/` remain active workflow assets. Role instructions mandate persona, accessibility, architecture and concurrency guidance in relevant phases. Three chats without a direct skill invocation do not establish obsolescence. Consolidate only after checking owners, references and future workflow needs; global/shared/bundled skills are outside repository cleanup scope.
