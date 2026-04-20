## ADDED Requirements

### Requirement: AttService SHALL request tracking authorization best-effort
AttService MUST check the current tracking authorization status and request authorization only when status is `notDetermined`. AttService MUST NOT throw and MUST treat failures as no-op.

#### Scenario: Already determined
- **WHEN** the current status is not `notDetermined`
- **THEN** AttService does not request authorization

### Requirement: AttService SHALL avoid repeated prompts per app session
AttService MUST ensure that request logic is performed at most once per app session (even if called multiple times due to lifecycle events).

#### Scenario: Multiple calls
- **WHEN** the host app calls `requestIfNeeded` multiple times in the same session
- **THEN** at most one request is made

### Requirement: ATT alignment MUST NOT block app boot
ATT request flow MUST be non-blocking relative to boot evaluation and routing. The host app MUST be able to trigger ATT request independently of boot.

#### Scenario: Boot proceeds regardless of ATT
- **WHEN** the app triggers ATT request during startup
- **THEN** boot routing continues without waiting for the ATT flow to complete

### Requirement: iOS Info.plist MUST include tracking usage description
Any iOS app that enables ATT alignment MUST include `NSUserTrackingUsageDescription` in `ios/Runner/Info.plist`.

#### Scenario: Runtime permission prompt
- **WHEN** the app attempts to request tracking authorization on iOS
- **THEN** the app has `NSUserTrackingUsageDescription` configured to avoid TCC crash

