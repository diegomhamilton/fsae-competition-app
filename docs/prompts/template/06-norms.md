# Norms Prompt

Apply the project norms to this task:

Task: `<paste task>`

Check the proposed work against these norms:

- TDD for models, services, coordinators, and view helpers
- Swift 6 and Concurrency-first boundaries
- SwiftUI views with small local UI state only
- Structured `Strings` enums for localizable text
- Stable accessibility identifiers separate from localized labels
- Feature scenarios as acceptance backbone
- One feature branch / PR per major slice unless review context gets too broad
- PR titles must start with `TASK#{TASK NUMBER}:` using the OpenSpec task number, for example `TASK#5.1: Add test case model tests`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes in PR description

Return any adjustments needed before implementation.
