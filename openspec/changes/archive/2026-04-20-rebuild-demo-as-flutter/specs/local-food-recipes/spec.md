## ADDED Requirements

### Requirement: User SHALL manage recipes locally
The app SHALL allow the user to create, view, and delete recipes with at least: name, ingredients, steps, cooking time, difficulty, optional image, and optional tips.

#### Scenario: Create a recipe
- **WHEN** the user completes the Add Recipe form and saves
- **THEN** the app persists the recipe locally and shows it in the recipe list

#### Scenario: Delete a recipe
- **WHEN** the user deletes a recipe from the recipe list
- **THEN** the app removes it from local storage and from the list UI

### Requirement: Recipe list SHALL support search by dish name
The recipe list SHALL allow filtering records using a keyword that matches recipe name case-insensitively.

#### Scenario: Keyword filters recipe list
- **WHEN** the user types a keyword into the recipe search field
- **THEN** the list shows only recipes whose name contains the keyword

### Requirement: Recipe list SHALL show an empty state when there are no results
The recipe screen SHALL show an empty state when there are no saved recipes or when filtering yields zero matches.

#### Scenario: Empty list shows empty state
- **WHEN** the user has no recipes saved
- **THEN** the recipe screen displays the empty state view

