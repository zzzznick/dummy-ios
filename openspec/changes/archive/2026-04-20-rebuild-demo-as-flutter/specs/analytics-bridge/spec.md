## ADDED Requirements

### Requirement: Analytics bridge SHALL initialize AppsFlyer when configured
If remote config `eventtype` equals `"af"`, the analytics bridge SHALL initialize AppsFlyer using `afkey` and `appid` before processing events.

#### Scenario: AppsFlyer configured
- **WHEN** the app receives remote config with `eventtype` `"af"` and non-empty `afkey` and `appid`
- **THEN** the app initializes AppsFlyer and begins sending events to AppsFlyer

### Requirement: Analytics bridge SHALL initialize Adjust when configured
If remote config `eventtype` equals `"ad"`, the analytics bridge SHALL initialize Adjust using `adkey` and production environment before processing events.

#### Scenario: Adjust configured
- **WHEN** the app receives remote config with `eventtype` `"ad"` and non-empty `adkey`
- **THEN** the app initializes Adjust in production environment and begins sending events to Adjust

### Requirement: Analytics bridge SHALL accept event forwarding from Web shells
The analytics bridge SHALL accept forwarded events containing an event name and event payload from Web Shell One and Web Shell Two.

#### Scenario: Web shell forwards an event
- **WHEN** a web shell forwards an event with name and payload
- **THEN** the analytics bridge maps and submits the event to the configured provider

### Requirement: Adjust event mapping SHALL merge built-in tokens and remote adeventlist mapping
For Adjust (`eventtype` `"ad"`), the analytics bridge SHALL build an event-token map from:
- built-in defaults
- `adeventlist` JSON mapping from event name to event token (if present and valid JSON)

#### Scenario: adeventlist provides mapping
- **WHEN** `adeventlist` contains a valid JSON object mapping event names to tokens
- **THEN** the analytics bridge uses those tokens for corresponding Adjust events

### Requirement: Revenue events SHALL be handled with provider-specific conventions
For event names in `{firstrecharge, recharge, withdrawOrderSuccess}` the analytics bridge SHALL submit revenue and currency fields using the provider conventions and SHALL treat `withdrawOrderSuccess` revenue as negative.

#### Scenario: withdrawOrderSuccess is negative revenue
- **WHEN** the web shell forwards `withdrawOrderSuccess` with `amount` and `currency`
- **THEN** the analytics bridge submits revenue as `-amount` with the provided currency

