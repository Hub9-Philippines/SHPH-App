# Spec Delta

## Purpose

Resolves a pinned map coordinate into verified Philippine Standard Geographic Code (PSGC) entities — region, province, city/municipality, barangay — and synchronizes the address form's cascading selectors from that result, degrading safely to manual selection when the match fails or cannot be trusted.

## ADDED Requirements

### Requirement: Pinned coordinates resolve to PSGC entities
When the client confirms a pinned map location, the system SHALL resolve the pinned latitude and longitude against `POST /api/v1/geocode/psgc-resolve` and SHALL obtain the PSGC region, province, city/municipality, and barangay identifiers and names together with a confidence score. The pinned coordinates themselves SHALL NOT be altered by resolution.

#### Scenario: Successful resolution
- **WHEN** the client confirms a pin at coordinates inside the Philippines and the endpoint returns a complete payload (for example region "National Capital Region (NCR)", province "Metro Manila", city "Pasig City", barangay "San Antonio", confidence `0.98`)
- **THEN** the pin screen completes confirmation using the returned coordinates and carries the full PSGC payload forward to the address form

#### Scenario: Resolution shows progress
- **WHEN** resolution is still in flight after the client confirms a pin
- **THEN** the pin screen shows a resolving state and does not finish confirmation until the resolution succeeds, fails, or times out

#### Scenario: Pin coordinates are preserved
- **WHEN** resolution succeeds, fails, or returns a low-confidence match
- **THEN** the latitude and longitude carried forward are exactly the pinned coordinates

### Requirement: Address form cascade synchronizes from a resolved payload
On receiving a resolved PSGC payload, the address form SHALL select region, then province, then city/municipality, then barangay in that order so that every selected identifier is valid within the PSGC cascade, and SHALL display the resolved names without requiring the user to pin again.

#### Scenario: Fresh form auto-fills all four selectors
- **WHEN** the user opens a new address form after a successful pin resolution
- **THEN** the region, province, city/municipality, and barangay selectors all show the resolved values and each subsequent selector's options are loaded for the level above it

#### Scenario: Manual override after auto-fill
- **WHEN** the user changes any selector after the cascade was auto-filled
- **THEN** the dependent lower-level selectors reset to a valid state for the new selection and the user can complete and save the address manually

#### Scenario: Editing an existing address with a new pin
- **WHEN** the user re-pins the location while editing an existing saved address and resolution succeeds
- **THEN** the cascade selectors update to the newly resolved geography while the address's other editable fields remain untouched

#### Scenario: NCR pin where the region has no province level
- **WHEN** the resolved region is National Capital Region, whose local PSGC data contains no province entries, and the payload's province is "Metro Manila"
- **THEN** region, city/municipality, and barangay auto-fill from the payload with cities loaded directly under the region, and the province field displays the resolved province name for saving instead of blocking the fill

### Requirement: Resolution failures degrade to manual selection
A resolution attempt that fails — HTTP 400, HTTP 422 (coordinates outside the Philippines), transport error, timeout, or a response missing any required PSGC field — SHALL be treated as an unresolved location: the address form stays fully usable with manual cascade selection, a non-blocking notice explains that the location could not be identified, and saving the address is never blocked by the failure.

#### Scenario: Coordinates outside the Philippines
- **WHEN** the endpoint responds 422 for a pin outside Philippine boundaries
- **THEN** the pin is accepted with its raw coordinates, no cascade auto-fill is attempted, and the address form shows a non-blocking "location could not be identified" notice with all selectors manually selectable

#### Scenario: Network failure or timeout
- **WHEN** the resolve request cannot reach the endpoint or exceeds the client timeout
- **THEN** the flow behaves as unresolved: manual selection remains available and no retry loop blocks the user

#### Scenario: Address still saves after failure
- **WHEN** resolution failed and the user manually picks region through barangay and taps save
- **THEN** the address saves normally with the pinned coordinates

#### Scenario: Matched identifiers absent from local PSGC data
- **WHEN** the payload is complete but a resolved region, city/municipality, or barangay (its code and its name) cannot be matched against the local PSGC dataset
- **THEN** no selectors are auto-filled and the failure notice is shown, except that an unmatched province level alone does not block auto-fill of the other levels

### Requirement: Low-confidence matches are not auto-applied
The system SHALL apply cascade auto-fill only when the returned `confidence_score` meets or exceeds the configured confidence threshold. Below the threshold the payload SHALL be treated as unresolved: no selector values change, and the non-blocking notice is shown.

#### Scenario: High-confidence match is applied
- **WHEN** the payload's `confidence_score` is at or above the threshold
- **THEN** the cascade selectors auto-fill with the resolved PSGC values

#### Scenario: Low-confidence match is withheld
- **WHEN** the payload's `confidence_score` is below the threshold
- **THEN** no selector values are changed and the user is notified that the location needs manual confirmation

### Requirement: Malformed responses are treated as failed resolution
The client SHALL accept a resolution response only when every required field — both PSGC identifiers and names for all four levels plus the confidence score — is present and well-formed; any response missing or invalidating those fields SHALL follow the failure behavior instead of partially filling selectors.

#### Scenario: Partial payload
- **WHEN** the response contains region and province fields but omits the barangay fields
- **THEN** no selectors are auto-filled and the failure notice is shown
