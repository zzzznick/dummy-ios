## ADDED Requirements

### Requirement: AnalyticsBridge SHALL configure from remote-config eventType
AnalyticsBridge MUST support configuration using remote-config fields:
- If eventType == `af` → initialize AppsFlyer using `afKey` and `appId`
- If eventType == `ad` → initialize Adjust using `adKey`
- Otherwise → remain unconfigured

#### Scenario: Unknown event type
- **WHEN** eventType is neither `af` nor `ad`
- **THEN** AnalyticsBridge remains unconfigured and ignores subsequent track calls

### Requirement: AnalyticsBridge trackEvent MUST be safe and non-throwing
Calling `trackEvent(name, payload)` MUST NOT throw, regardless of SDK state, payload shape, or SDK failures. If analytics is not configured, `trackEvent` MUST be a no-op.

#### Scenario: trackEvent before configure
- **WHEN** the host calls `trackEvent` before any successful `configure`
- **THEN** the call is ignored and does not crash

### Requirement: AnalyticsBridge SHALL apply revenue event parity rules
AnalyticsBridge MUST treat the following event names as revenue events with parity behavior:
- `firstrecharge`
- `recharge`
- `withdrawOrderSuccess` (revenue amount MUST be negative)

For these events, AnalyticsBridge MUST attempt to read amount from `amount` or `af_revenue`, and currency from `currency`. If either is missing/invalid, AnalyticsBridge MUST fall back to normal event logging without revenue fields.

#### Scenario: Withdraw revenue
- **WHEN** event `withdrawOrderSuccess` is tracked with amount and currency
- **THEN** AnalyticsBridge logs revenue as a negative amount

### Requirement: AnalyticsBridge SHALL build Adjust token map from remote-config
When using Adjust, AnalyticsBridge MUST build an event token map by merging:
- a built-in default map (for parity)
- a remote-config JSON map provided via `adEventListRaw` (remote values MUST override defaults when keys collide)

#### Scenario: Remote overrides default token
- **WHEN** remote-config provides a token for an existing default key
- **THEN** AnalyticsBridge uses the remote token for that event

