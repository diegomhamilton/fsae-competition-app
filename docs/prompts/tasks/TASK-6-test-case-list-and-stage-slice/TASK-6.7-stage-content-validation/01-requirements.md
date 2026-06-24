# Requirements Prompt

You are helping with SPDD for this task:

Task: `6.7 Manually validate Garage, EV, Egress, and Rain stage content against Design/Resources/InspectionEvent/*.json.`

Describe the essence of the requirement in one clear sentence.

Then list:

- User-visible outcome for a judge reviewing JSON-backed stages
- Acceptance source, especially `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature`
- JSON source files to validate
- Required behavior
- Out of scope behavior
- Completion signal

Keep this focused on what must be true, not how to build it.

Context:

- Expected PR title: `TASK#6.7: Validate stage content`
- Branch: `codex/task-6.7-stage-content-validation`
- This task depends on TASK#6.1 through TASK#6.6.
- Validate at least Garage, EV, Egress, and Rain stage content against bundled JSON, including ordering, sections, test cases, steps, rule references, validation blockers, submit state, energized badges, and accessibility-equivalent safety information.
- If the app cannot be run or inspected in this task, prepare the checklist and PR validation-note draft without claiming manual validation is complete.
- Do not build automatically; user owns builds and manual app validation unless explicitly requested.
