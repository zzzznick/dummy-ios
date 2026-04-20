## ADDED Requirements

### Requirement: Web Shell Two SHALL load the provided URL in an in-app WebView
Web Shell Two SHALL present an in-app WebView that loads the URL provided by boot routing.

#### Scenario: Initial page load
- **WHEN** the app navigates to Web Shell Two with a non-empty URL
- **THEN** the WebView loads the URL via a standard navigation request

### Requirement: Web Shell Two SHALL set a custom User-Agent
Web Shell Two SHALL set a custom User-Agent string that includes `AppShellVer:1.0.0` and device identifiers consistent with the iOS demo behavior.

#### Scenario: Request uses custom User-Agent
- **WHEN** the WebView issues a network request
- **THEN** the request includes the custom User-Agent value

### Requirement: Web Shell Two SHALL receive messages for eventTracker and openSafari channels
Web Shell Two SHALL accept:
- `eventTracker`: object payload containing `eventName` and `eventValue` (where `eventValue` may be a JSON string or JSON object)
- `openSafari`: object payload containing `url`

#### Scenario: eventTracker received
- **WHEN** the page sends an `eventTracker` message
- **THEN** the app parses `eventValue` as JSON (if needed) and forwards the event to analytics bridge

#### Scenario: openSafari received
- **WHEN** the page sends an `openSafari` message with a non-empty `url`
- **THEN** the app opens that `url` via the system URL handler

### Requirement: Web Shell Two SHALL handle new window navigation with t.me exception and inappjump behavior
When the WebView requests opening a URL in a new window, Web Shell Two SHALL follow the same rule set as Web Shell One (t.me always external; otherwise respect `inappjump`).

#### Scenario: t.me is always external
- **WHEN** a new-window navigation target has host containing `t.me`
- **THEN** the app opens it externally and does not load it in the WebView

#### Scenario: inappjump true loads in-app
- **WHEN** a new-window navigation occurs AND `inappjump` equals `"true"`
- **THEN** the app loads the request in the current WebView

#### Scenario: inappjump false opens externally
- **WHEN** a new-window navigation occurs AND `inappjump` is not `"true"`
- **THEN** the app opens the URL externally

