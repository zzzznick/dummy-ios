## ADDED Requirements

### Requirement: Inject jsBridge.postMessage for web-to-native messaging
When a namespaced in-app web container is used (platform `"1"` or `"2"`), the system MUST ensure the web page can call `window.jsBridge.postMessage(name, data)` and have the message delivered to the existing namespaced web→native pipeline.

#### Scenario: Page can call jsBridge.postMessage
- **WHEN** the first document is loaded in the in-app web container
- **THEN** `window.jsBridge.postMessage` MUST exist and be callable from page JavaScript without throwing

#### Scenario: jsBridge message reaches native event handling
- **WHEN** the page calls `window.jsBridge.postMessage("evt_x", "{\"k\":1}")`
- **THEN** native MUST receive a message that is handled best-effort (no crash) by the namespaced bridge

### Requirement: Inject WgPackage metadata
When a namespaced in-app web container is used, the system MUST expose an in-page object `window.WgPackage` containing app identity metadata.

#### Scenario: WgPackage exists with required fields
- **WHEN** the first document is loaded in the in-app web container
- **THEN** `window.WgPackage` MUST exist
- **AND THEN** it MUST contain a non-empty `name`
- **AND THEN** it MUST contain a non-empty `version`

### Requirement: Handle openWindow/openSafari via inAppJump decision
The system MUST implement the demo-equivalent open behavior for web-triggered navigation commands.

#### Scenario: openWindow opens externally when inAppJump is false
- **WHEN** native receives an event with name `openWindow` and payload containing `url`
- **AND WHEN** `inAppJump` is not truthy
- **THEN** the system MUST open the `url` externally
- **AND THEN** the in-app web container MUST NOT navigate to that `url`

#### Scenario: openWindow navigates in-app when inAppJump is true
- **WHEN** native receives an event with name `openWindow` and payload containing `url`
- **AND WHEN** `inAppJump` is truthy
- **THEN** the in-app web container MUST navigate to that `url` in the current container

#### Scenario: openSafari follows the same decision matrix
- **WHEN** native receives an event with name `openSafari` and payload containing `url`
- **THEN** it MUST follow the same decision rules as `openWindow`

### Requirement: Intercept new-window navigations and enforce t.me external-open
The in-app web container MUST intercept new-window navigations and apply forced external-open rules consistent with demo behavior.

#### Scenario: t.me is always opened externally
- **WHEN** a navigation is requested whose host contains `t.me`
- **THEN** the system MUST open the URL externally
- **AND THEN** the in-app web container MUST prevent the navigation

#### Scenario: Non-main-frame navigation obeys inAppJump
- **WHEN** a navigation is requested that is not a main-frame navigation (i.e., new window / popup)
- **AND WHEN** `inAppJump` is truthy
- **THEN** the in-app web container MUST allow navigation in-app

#### Scenario: Non-main-frame navigation opens externally when inAppJump is false
- **WHEN** a navigation is requested that is not a main-frame navigation (i.e., new window / popup)
- **AND WHEN** `inAppJump` is not truthy
- **THEN** the system MUST open the URL externally
- **AND THEN** the in-app web container MUST prevent the navigation

### Requirement: Maintain auditability constraints in generated code
All generated code for this capability MUST maintain the existing auditability constraints.

#### Scenario: No logs in generated lib code
- **WHEN** scanning `apps/<app>/lib/**.dart`
- **THEN** forbidden log/print tokens MUST NOT exist (minimum: `print(`, `debugPrint(`, `developer.log(`, `Logger(`)

#### Scenario: No visible titles and black safe areas remain enforced
- **WHEN** running the app with the in-app web container
- **THEN** the container MUST NOT display any title text in a navigation bar / AppBar
- **AND THEN** the top and bottom safe areas MUST render with black background using container-only widget structure

