## MODIFIED Requirements

### Requirement: Call and Message actions present contact choosers
The booking details page SHALL present two floating instant-action buttons for Call and Message. Tapping Call SHALL open a chooser offering call by phone number (OS dialer) or call using the app's communication system; tapping Message SHALL open a chooser offering text via SMS (OS SMS app) or the in-app chat room. Neither button SHALL route directly through the legacy contact hub page.

#### Scenario: Call action offers two choices
- **WHEN** the user taps the floating Call button on the booking details page
- **THEN** a chooser appears with "call by number" and "call using the app" options, and the legacy contact hub page is not opened

#### Scenario: Message action offers two choices
- **WHEN** the user taps the floating Message button on the booking details page
- **THEN** a chooser appears with "text via SMS" and "chat in app" options, and the legacy contact hub page is not opened

#### Scenario: In-app chat opens a real chat room
- **WHEN** the user chooses "chat in app" from the Message chooser
- **THEN** the in-app chat room for the provider opens with the app's communication system