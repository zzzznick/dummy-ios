## ADDED Requirements

### Requirement: App SHALL request ATT authorization when becoming active on iOS
On iOS, when the app becomes active, it SHALL check the ATT authorization status and SHALL request authorization if status is not determined.

#### Scenario: Status not determined triggers request
- **WHEN** the app becomes active AND ATT status is not determined
- **THEN** the app requests ATT authorization from the user

### Requirement: App SHALL not block boot routing on ATT authorization
ATT authorization flow SHALL NOT block remote-config fetch, routing, or initial screen presentation.

#### Scenario: ATT request runs in parallel
- **WHEN** the app becomes active and triggers ATT request
- **THEN** the app still proceeds with remote-config routing and UI navigation

