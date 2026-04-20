## ADDED Requirements

### Requirement: Bootkit SHALL support injected remote-config endpoint
Bootkit MUST NOT hardcode the remote-config endpoint. The host app MUST be able to provide an endpoint string at runtime (e.g. via constructor injection).

#### Scenario: App provides endpoint
- **WHEN** the host app constructs the remote-config client with an explicit endpoint
- **THEN** Bootkit fetches configuration from that endpoint

### Requirement: Bootkit SHALL retry remote-config fetch without crashing
Bootkit MUST retry remote-config fetch on errors using an exponential backoff strategy. Bootkit MUST NOT crash the app if remote-config fetch fails.

#### Scenario: Temporary network failure then success
- **WHEN** the initial remote-config request fails
- **THEN** Bootkit retries with backoff until a request succeeds

### Requirement: Bootkit SHALL re-attempt evaluation when connectivity changes
Bootkit MUST listen for connectivity changes during startup evaluation. If evaluation has not completed, Bootkit MUST re-attempt remote-config fetch and routing on connectivity changes.

#### Scenario: Offline to online during boot
- **WHEN** the app starts offline and later becomes online before evaluation completes
- **THEN** Bootkit triggers a new evaluation attempt

### Requirement: Bootkit SHALL decide destination based on remote-config
Bootkit MUST determine the boot destination using remote-config fields, with the following default behavior:
- If config is missing OR url is empty → local destination
- If platform == 1 → Web Shell One
- If platform == 2 → Web Shell Two
- If platform == 3 → external open
- Otherwise → local destination

#### Scenario: Null config
- **WHEN** remote-config returns null or invalid data
- **THEN** Bootkit routes to the local destination

### Requirement: Bootkit SHALL configure analytics only when needed
Bootkit MUST NOT block navigation to the local destination on analytics initialization. If the destination is Web Shell One/Two or external, Bootkit MUST attempt to configure analytics from remote-config before routing.

#### Scenario: Local destination
- **WHEN** boot decision is local destination
- **THEN** Bootkit routes to local destination without requiring analytics configuration

### Requirement: Bootkit SHALL route via host-provided local destination builder
Bootkit MUST allow the host app to provide the local destination page via a builder/factory function. Bootkit MUST NOT directly depend on app-specific UI pages.

#### Scenario: Custom local home page
- **WHEN** the host app provides a custom local destination builder
- **THEN** Bootkit routes to that page when the decision is local destination

