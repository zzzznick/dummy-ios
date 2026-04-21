## ADDED Requirements

### Requirement: App SHALL parse remote-config using an injected keyset
The app SHALL interpret the first object of the remote-config response using an injected keyset that defines the JSON keys for each semantic field: `url`, `platform`, `eventtype`, `afkey`, `appid`, `adkey`, `adeventlist`, `inappjump`.

#### Scenario: Remote-config item parsed with keyset
- **WHEN** the remote-config endpoint returns a non-empty list and the first item contains the keys defined by the injected keyset
- **THEN** the app parses the first item into a `RemoteConfigItem` using the keyset mapping

#### Scenario: Missing keys yield empty strings
- **WHEN** the remote-config first item is missing one or more keyset-defined keys
- **THEN** the app treats the missing values as empty strings and continues evaluation without crashing

### Requirement: App SHALL use only keyset-defined JSON keys by default
By default, the app SHALL NOT rely on fixed plaintext JSON keys (`url`, `platform`, `eventtype`, `afkey`, `appid`, `adkey`, `adeventlist`, `inappjump`) during remote-config parsing.

#### Scenario: Keyset only parsing
- **WHEN** the remote-config first item contains only plaintext keys and does not contain the keyset-defined keys
- **THEN** the parsed `RemoteConfigItem` fields are empty strings and the boot decision evaluates accordingly

### Requirement: Build pipeline SHALL generate per-app random remote-config keys and document mapping
For each generated app (jacket), the build/generation pipeline SHALL generate a unique set of random remote-config JSON keys and persist them in the app codebase, and SHALL output a mapping document in the app README.

#### Scenario: README includes mapping table
- **WHEN** a new app is generated
- **THEN** the generated README contains a mapping from random keys to semantic field names: `url`, `platform`, `eventtype`, `inappjump`, `afkey`, `appid`, `adkey`, `adeventlist`

#### Scenario: README includes remote_url response example
- **WHEN** a new app is generated
- **THEN** the generated README includes a copy-pastable `remote_url` response example that uses the random keys and matches the expected list-of-objects response shape

### Requirement: Pipeline MAY provide an optional compatibility mode (generated per app)
The pipeline MAY generate an optional compatibility mode for a specific app, where parsing attempts the random keys first and then falls back to plaintext keys when random keys are absent.

#### Scenario: Compatibility mode fallback
- **WHEN** compatibility mode is enabled for an app AND the remote-config first item lacks random keys but includes plaintext keys
- **THEN** the app parses values from the plaintext keys for that session
