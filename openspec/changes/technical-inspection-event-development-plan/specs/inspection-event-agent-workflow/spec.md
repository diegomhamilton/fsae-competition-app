## ADDED Requirements

### Requirement: Planning PR defines phase ownership by agent
The system delivery plan SHALL include a plan proposal PR that identifies which agent owns each phase of the technical inspection workflow.

#### Scenario: Plan proposal identifies agents
- **WHEN** PR 1 is opened
- **THEN** it documents Architect, Tester, Planner, Developer, and Documenter agent responsibilities for each implementation phase.

#### Scenario: Plan proposal references feature file
- **WHEN** PR 1 describes acceptance strategy
- **THEN** it references `Design/UserStories/InspectionEvents/features/inspection_event_use_cases.feature` as the source for testing scenarios.

### Requirement: Agent files define responsibilities and skill usage
The system delivery plan SHALL include dedicated agent markdown files that state each agent's inputs, outputs, responsibilities, and required skills.

#### Scenario: Architect agent file
- **WHEN** PR 2 adds the Architect agent file
- **THEN** it instructs the agent to use the `.feature` file to propose MVC architecture with Models, Views, Coordinators, and Services.

#### Scenario: Tester agent file
- **WHEN** PR 2 adds the Tester agent file
- **THEN** it instructs the agent to use personas to create unit, UI, snapshot, positive, negative, and edge-case scenarios.

#### Scenario: Planner agent file
- **WHEN** PR 2 adds the Planner agent file
- **THEN** it instructs the agent to sequence small manual-validation features and maintain documented branch, commit, squash, and merge workflow.

#### Scenario: Developer agent file
- **WHEN** PR 2 adds the Developer agent file
- **THEN** it instructs the agent to implement the Architect agent's proposal using Swift 6, SwiftUI, and Concurrency-first services.

#### Scenario: Documenter agent file
- **WHEN** PR 2 adds the Documenter agent file
- **THEN** it instructs the agent to use YAML frontmatter and technical report style for documentation, impact, use cases, and tutorials.

### Requirement: Skill files guide specialized implementation work
The system delivery plan SHALL include skill markdown files for Accessibility, Concurrency Developer, SwiftUI Developer, Animation Developer, Architecture Developer, and Personas.

#### Scenario: Skill files are added before implementation
- **WHEN** PR 3 is opened
- **THEN** it adds the requested skill files and references how agents must use each skill.

#### Scenario: Persona files guide testing
- **WHEN** persona skill files are used
- **THEN** Judge and Student personas receive priority, with Professor, Fans, and Sponsors used for secondary scenario discovery.

### Requirement: Git workflow keeps implementation reviewable
The system delivery plan SHALL use task branches and squash merges to keep the worktree clean and the commit history documented.

#### Scenario: Feature slice branch
- **WHEN** an implementation slice begins
- **THEN** the Planner agent defines a task branch, manual validation goal, test scope, and squash-merge notes.

#### Scenario: Dedicated UI test PR
- **WHEN** XCUITests and snapshot tests are introduced
- **THEN** they are added through a dedicated PR after accessibility identifiers and stable navigation hooks exist.
