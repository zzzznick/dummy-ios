## ADDED Requirements

### Requirement: User SHALL manage diary entries locally
The app SHALL allow the user to create, view, and delete food diary entries with at least: content text, optional photo, and timestamp.

#### Scenario: Create a diary entry
- **WHEN** the user creates a diary entry with content and saves
- **THEN** the app persists the entry locally and shows it in the diary list

#### Scenario: Delete a diary entry
- **WHEN** the user deletes a diary entry from the diary list
- **THEN** the app removes it from local storage and from the list UI

### Requirement: Diary list SHALL support search by content
The diary list SHALL allow filtering entries using a keyword that matches diary content case-insensitively.

#### Scenario: Keyword filters diary list
- **WHEN** the user types a keyword into the diary search field
- **THEN** the list shows only entries whose content contains the keyword

### Requirement: Diary list SHALL show an empty state when there are no entries
The diary screen SHALL show an empty state view when there are no diary entries.

#### Scenario: Empty list shows empty state
- **WHEN** the user has no diary entries saved
- **THEN** the diary screen displays the empty state view

