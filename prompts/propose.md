# Propose development plan for FSAE competition app
Focus right now in technical inspection event.

#/Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature defines the use cases covered by the app.

- Focus implementation so we can build app from scratch based in existing views. Describe flow since the login to submission and rechecks.
- Recheck is any failure at test cases described at multiple JSON files: /Design/Resources/InspectionEvent/*.json, teams needs to fix issue and review with judge before receiving inspection stickers.
- Development flow should be:
    - Test step view, mock JSONs
    - Test case view, mock JSONs
    - Test case list view, from JSONs
- Propose classes and unit tests (TDD)
- Always referer to the .feature file for details on testing scenarios
- Use Swift 6, SwiftUI and Concurrency-first
- Let's keep an eye in accessibility, define identifiers, cover XCUITests to make sure that items are accessible with positive, negative and edge cases
- Use localizable strings with structured constant enums in each file
- UI tests should be integrated in dedicated PR


## Multi-agent
We'll have dedicated agents to handle our work.

The flow should be:
- Architect agent: uses .feature to propose an architecture, in MVC (Model, View, Coordinator + Services)
- Tester agent: uses Personas to create multiple scenarios, unit tests for Coordinator, Model and View helpers, UI tests and Snapshot testing where possible.
- Planner agent: takes into consideration development flow to propose incremental features that allow validate the app manually in small steps, while keeping a clean worktree and commit history through squash and merge features, task branches and strongly docummented git workflow.
- Developer agent: uses Swift development skills to implement architecture proposed by architect
- Documenter agent: creates a cool YAML frontmatter for documentation files, improving indexing for LLM context. Uses a technical and direct, almost engineering technical report level, to describe features, impact and uses cases. Add tutorials where applicable.
- Skills
    - Accessitibility: adds accessibility identifiers, make sure colors choices do not cause confusion for visually impaired users. Guarantee that all flows can be performed using voice over.
    - Concurrency developer: designs concurrency-safe software using Modern swift
    - SwiftUI developer: UI specialyst
    - Animation developer: make cool animation when tests passes or fail, switching smoothly between test steps.
    - Architecture developer: write unit tests and folder structure.
    - Personas: folder with multiple markdowns, each persona should be used to create different test scenarions.
        - Judge (priority)
        - Student (priority)
        - Professor
        - Fans
        - Sponsors

Now run:
/opsx:propose to create the plan following my guidelines above, PRs:
1. should be plan proposal, highlight agents usage for each phase of the workflow.
2. should add the agents .md files: mention skills usage for each agent.
3. should add the skills .md files;
