# Active inspection design

Maintain the design alongside implementation using these sources:

- [System map](../docs/system-map.md): actual screens, coordinator ownership, persistence and service wiring.
- [Inspection UI behavior](../docs/simplified-ui-redesign-plan.md): queue, focus, review, correction and confirmation interactions.
- [Judge navigation requirements](Flows/InspectionEvents/JUDGE_NAVIGATION.md): navigation acceptance boundaries.
- [Behavioral scenarios](UserStories/InspectionEvents/features/inspection_event_use_cases.feature): judge/team acceptance scenarios.
- [Active backlog](../openspec/changes/technical-inspection-event-development-plan/tasks.md): unfinished capabilities and validation gaps, including disabled team switching and deferred history/rechecks/stickers.
- [Validation](../docs/validation.md): source-qualified checks and remaining manual scenarios.
- [Official content](Resources/InspectionEvent/): inspection JSON content sources; bundled copies are under the application’s InspectionEvent directory.

Do not maintain separate phase screen maps, MVVM blueprints, completed epic plans or old proposal galleries. Update the system map and UI behavior when implementation changes. Requirements for deferred capabilities do not imply that those screens exist.
