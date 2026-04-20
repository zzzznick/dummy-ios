## ADDED Requirements

### Requirement: App SHALL fetch remote config on boot
The app SHALL perform an HTTP GET request to the configured remote-config endpoint on startup to determine the initial navigation path.

#### Scenario: Startup fetch succeeds
- **WHEN** the app launches and network is available
- **THEN** the app fetches remote config and evaluates routing based on the first item in the returned list

### Requirement: App SHALL route based on remote config fields
The app SHALL interpret the first object of the remote-config response using the following keys: `url`, `platform`, `eventtype`, `afkey`, `appid`, `adkey`, `adeventlist`, `inappjump`.

#### Scenario: url is empty
- **WHEN** the remote config `url` is an empty string
- **THEN** the app navigates to the local tab UI

#### Scenario: url is non-empty and platform is 1
- **WHEN** the remote config `url` is non-empty AND `platform` equals `"1"`
- **THEN** the app navigates to Web Shell One and loads the `url`

#### Scenario: url is non-empty and platform is 2
- **WHEN** the remote config `url` is non-empty AND `platform` equals `"2"`
- **THEN** the app navigates to Web Shell Two and loads the `url`

#### Scenario: url is non-empty and platform is 3
- **WHEN** the remote config `url` is non-empty AND `platform` equals `"3"`
- **THEN** the app opens the `url` in the system browser and does not show the local tab UI

### Requirement: App SHALL retry remote config on network recovery
If the app has not successfully evaluated remote config yet, it SHALL retry fetching remote config when connectivity changes from offline to online.

#### Scenario: Network becomes reachable after initial offline
- **WHEN** the app launches without connectivity AND later connectivity becomes available
- **THEN** the app retries fetching remote config and re-evaluates routing

### Requirement: App SHALL avoid duplicate remote-config evaluation per session
Within a single app session, once the app has successfully evaluated remote config, it SHALL NOT re-run routing evaluation again unless the process is restarted.

#### Scenario: Multiple connectivity change events
- **WHEN** connectivity changes multiple times after a successful remote-config evaluation
- **THEN** the app does not re-run routing evaluation again

