# Entities Prompt

For this task:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

Identify the core entities and relationships.

Include:

- Service protocols or concrete service types
- Async loading boundaries
- Bundle/resource identifiers
- Stage, section, test case, and test step models used by the service
- Decoder configuration
- Typed error cases
- Test fixture and bundled resource relationships
- Data needed by later stage/list views, validation, accessibility IDs, and energized badges

Required entity coverage:

- `InspectionContentService`
- `InspectionStage`
- `InspectionSection`
- `InspectionTestCase`
- `InspectionTestStep`
- `InspectionContentLoadingError` or equivalent typed error
- `Design/Resources/InspectionEvent/01_garage_inspection.json`
- `Design/Resources/InspectionEvent/02_body_inspection.json`
- `Design/Resources/InspectionEvent/03_chassis_inspection.json`
- `Design/Resources/InspectionEvent/04_ev_inspection.json`
- `Design/Resources/InspectionEvent/05_egress_test.json`
- `Design/Resources/InspectionEvent/06_rain_test.json`

Call out whether the JSON resources are currently part of the app bundle or need Xcode project membership work.
