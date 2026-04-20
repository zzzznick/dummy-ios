## ADDED Requirements

### Requirement: User SHALL manage feast records locally
The app SHALL allow the user to create, view, update, and delete feast records with at least: restaurant name, dish names, dining date, number of people, cost, and an optional photo.

#### Scenario: Create a feast record
- **WHEN** the user completes the Add Feast form and confirms save
- **THEN** the app persists the record locally and shows it in the feast list

#### Scenario: Delete a feast record
- **WHEN** the user deletes a feast record from the list
- **THEN** the app removes it from local storage and from the list UI

### Requirement: Feast list SHALL support search by restaurant or dish names
The feast list SHALL allow filtering records using a keyword that matches restaurant name or dish names case-insensitively.

#### Scenario: Keyword filters feast list
- **WHEN** the user types a keyword into the feast search field
- **THEN** the list shows only feast records whose restaurant name or dish names contain the keyword

### Requirement: Feast list SHALL support sort preference persistence
The feast list SHALL support sorting by date (ascending/descending) and cost (ascending/descending) and SHALL persist the current sort preference across app launches.

#### Scenario: Sort preference persists
- **WHEN** the user changes sort to cost descending and restarts the app
- **THEN** the feast list is displayed using cost descending sort

### Requirement: Feast list SHALL display total cost
The feast screen SHALL display the total cost computed as the sum of all feast record costs.

#### Scenario: Total cost updates after adding record
- **WHEN** the user adds a new feast record with a cost value
- **THEN** the displayed total cost increases by that value

### Requirement: App SHALL attempt feast data restore from backup on local entry
When the app enters the local tab UI, it SHALL check for a feast backup and restore it if present.

#### Scenario: Backup exists and is restored
- **WHEN** a feast backup exists at startup
- **THEN** the app restores feast data before showing the feast list

### Requirement: App SHALL support creating a feast backup
The app SHALL provide an internal mechanism to create a backup copy of feast data to a dedicated backup location.

#### Scenario: Backup is created
- **WHEN** the app triggers a feast backup operation
- **THEN** a backup copy is written and can later be restored

