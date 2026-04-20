## ADDED Requirements

### Requirement: Web Shell One SHALL load the provided URL in an in-app WebView
Web Shell One SHALL present an in-app WebView that loads the URL provided by boot routing.

#### Scenario: Initial page load
- **WHEN** the app navigates to Web Shell One with a non-empty URL
- **THEN** the WebView loads the URL via a standard navigation request

### Requirement: Web Shell One SHALL inject jsBridge and WgPackage at document start
Web Shell One SHALL inject a `window.jsBridge.postMessage(name, data)` bridge and a `window.WgPackage` object containing the app identifier and app version.

#### Scenario: Page script reads injected objects
- **WHEN** a page script executes at document start
- **THEN** `window.jsBridge` and `window.WgPackage` are available

### Requirement: Web Shell One SHALL receive messages for Post and event channels
Web Shell One SHALL accept two message formats:
1) `Post`: object payload containing `{name, data}` where `data` is a JSON string
2) `event`: string payload formatted as `<name>+<data>` where `data` is a JSON string

#### Scenario: Post message received
- **WHEN** the page sends a `Post` message with `{name, data}`
- **THEN** the app parses `data` as JSON and processes it using `name`

#### Scenario: event message received
- **WHEN** the page sends an `event` message as `<name>+<data>`
- **THEN** the app parses `data` as JSON and processes it using `name`

### Requirement: Web Shell One SHALL open external URLs for openWindow
If a received message has `name` equal to `openWindow`, Web Shell One SHALL open `json.url` using the system URL handler.

#### Scenario: openWindow opens system browser
- **WHEN** the page sends `openWindow` with `data` containing a JSON object with a non-empty `url`
- **THEN** the app opens that `url` via the system URL handler

### Requirement: Web Shell One SHALL forward non-openWindow messages to analytics
If a received message has `name` not equal to `openWindow`, Web Shell One SHALL forward the event to the analytics bridge based on the configured `eventtype`.

#### Scenario: Non-openWindow triggers analytics
- **WHEN** the page sends an event where `name` is not `openWindow`
- **THEN** the app forwards the event name and event payload to the analytics bridge

### Requirement: Web Shell One SHALL handle new window navigation with t.me exception and inappjump behavior
When the WebView requests opening a URL in a new window, Web Shell One SHALL:
- open externally if host contains `t.me`
- otherwise, if `inappjump` equals `"true"`, load the request in the same WebView
- otherwise open externally via the system URL handler

#### Scenario: t.me is always external
- **WHEN** a new-window navigation target has host containing `t.me`
- **THEN** the app opens it externally and does not load it in the WebView

#### Scenario: inappjump true loads in-app
- **WHEN** a new-window navigation occurs AND `inappjump` equals `"true"`
- **THEN** the app loads the request in the current WebView

#### Scenario: inappjump false opens externally
- **WHEN** a new-window navigation occurs AND `inappjump` is not `"true"`
- **THEN** the app opens the URL externally

