## ADDED Requirements

### Requirement: WebShells SHALL enforce a consistent external-navigation policy
WebShells MUST support an injected external navigation handler. WebShells MUST use it for:
- mandatory external hosts (e.g. `t.me`)
- user-triggered external opens when in-app jump is disabled

#### Scenario: t.me link
- **WHEN** a navigation request targets a host containing `t.me`
- **THEN** WebShells opens it externally and prevents in-webview navigation

### Requirement: WebShell One SHALL provide JS bridge injection and message channels
Web Shell One MUST:
- inject `window.jsBridge.postMessage(name,data)` to forward to a JS channel named `Post`
- inject `window.WgPackage` with app `name` and `version`
- listen to JS channels `Post` and `event` and parse them into `(name,payload)` events

#### Scenario: Post message received
- **WHEN** the JS channel `Post` receives a JSON payload containing `name` and `data`
- **THEN** Web Shell One converts it to an event and forwards it to the analytics bridge

### Requirement: WebShell Two SHALL provide custom UA and message channels
Web Shell Two MUST:
- set a custom User-Agent containing `AppShellVer` and device identifiers best-effort
- listen to JS channels `eventTracker` and `openSafari`
- parse `eventTracker` into `(eventName,eventValue)` and forward to analytics bridge

#### Scenario: eventTracker with string value
- **WHEN** the JS channel `eventTracker` receives a payload where eventValue is a string
- **THEN** Web Shell Two forwards it as a payload map compatible with analytics bridge

### Requirement: WebShells SHALL override window.open and handle open behavior
Both Web Shell One and Two MUST best-effort override `window.open(url)` to route open requests into the shell open handler.
The open handler MUST follow `inAppJump` from remote-config:
- if `inAppJump == 'true'` → load the url within the webview
- otherwise → open the url externally

#### Scenario: in-app jump enabled
- **WHEN** a window.open request is received and `inAppJump == 'true'`
- **THEN** the shell loads the url in the same webview

### Requirement: WebShells analytics forwarding MUST ignore shell-control events
WebShells MUST NOT forward shell-control events (e.g. open-window events used for navigation) to analytics tracking.

#### Scenario: open event
- **WHEN** the shell receives an open/navigation control event
- **THEN** the shell executes navigation and does not call analytics tracking for that control event

