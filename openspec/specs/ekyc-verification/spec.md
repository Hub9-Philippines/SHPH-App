## Purpose

Web-parity identity verification for SHPH providers: collect identity documents
(ID front/back plus provider-only NBI clearance, portfolio, resume), run a
server-driven facial liveness challenge, and submit everything to the KYC API so
verification status is tracked and reviewed on the backend like the web app.

### Requirement: Liveness challenge comes from the server
Before face verification, the app SHALL request a liveness challenge from
`POST /kyc/liveness/challenge/` and SHALL run the challenge plan returned
(actions such as centerFace, blink, smile, turnLeft, turnRight). If the
challenge request fails, the app SHALL fall back to a local plan, mirroring the
web behavior.

#### Scenario: Server provides a challenge plan
- **WHEN** the user starts face verification
- **THEN** the app requests a liveness challenge and executes its `plan` actions

#### Scenario: Challenge request fails
- **WHEN** the liveness challenge endpoint is unreachable
- **THEN** the app runs a fallback action plan (e.g., center face, blink, smile)
  and continues verification without a nonce

### Requirement: Face verification result is sent to the backend
The app SHALL capture a selfie and compute a liveness decision/score for the
captured frames, and SHALL include `selfie`, `challenge_nonce`, `liveness_score`,
and liveness metadata in the KYC submission. The app MUST NOT record
verification as complete locally only — the backend is the source of truth.

#### Scenario: Successful liveness capture is submitted
- **WHEN** the user completes the liveness actions
- **THEN** the app includes the selfie, challenge nonce, score, and metadata in
  the KYC submit payload

#### Scenario: Liveness decision blocks submission
- **WHEN** the liveness decision is `block`
- **THEN** the app does not submit KYC and prompts the user to retry

### Requirement: Document collection matches the web flow
The KYC document step SHALL collect an ID front and back image (via scanner or
camera), and for provider submissions also an NBI/political clearance (required),
plus optional portfolio and resume. The submitter role SHALL be sent as
`provider` or `customer` based on the flow.

#### Scenario: Client flow collects ID front and back
- **WHEN** a client runs KYC
- **THEN** the app collects ID front and back and submits them with
  `submitter_role: "customer"`

#### Scenario: Provider flow collects clearance and extras
- **WHEN** a provider runs KYC
- **THEN** the app additionally collects the NBI/political clearance (required)
  and optional portfolio and resume, and submits with `submitter_role: "provider"`

#### Scenario: Missing required documents blocks review
- **WHEN** the ID front/back (or NBI clearance for providers) are not all present
- **THEN** the app disables the review/submit action

### Requirement: KYC submission is multipart with web field names
The app SHALL submit KYC to `POST /kyc/submit/` as multipart/form-data using the
web field names: `id_front`, `id_back`, `selfie`, `nbi_clearance`, `portfolio`,
`resume`, `submitter_role`, `challenge_nonce`, `liveness_metadata`,
`liveness_score`.

#### Scenario: Provider submits KYC with documents and liveness
- **WHEN** a provider reviews and submits KYC with all required data
- **THEN** the app sends a multipart request containing the document files,
  selfie, nonce, score, and metadata

### Requirement: KYC status uses web vocabulary and is polled
The app SHALL read KYC status from `POST /kyc/status/` using the web vocabulary
(`not_submitted`, `rejected`, `pending`, and approved/verified), and SHALL poll
while pending so approval advances the user to the provider dashboard.

#### Scenario: Pending KYC advances on approval
- **WHEN** a provider's KYC is `pending` and the app polls and receives an
  approved status
- **THEN** the app routes the provider to the provider dashboard

#### Scenario: Rejected KYC surfaces the reason and offers resubmit
- **WHEN** a provider's KYC is `rejected`
- **THEN** the app shows the rejection reason and lets the provider resubmit

#### Scenario: Status fetch fails
- **WHEN** the KYC status endpoint errors during polling
- **THEN** the app tolerates the failure and keeps the current pending state
  without crashing

### Requirement: eKYC entry and status surface verification state
The app's KYC/status page SHALL reflect the current verification state to the
user (not started, under review, rejected, verified) with the correct actions,
and its navigation links SHALL point at real registered routes.

#### Scenario: Verified provider sees verified state
- **WHEN** a provider with approved KYC opens the KYC status page
- **THEN** the page shows a verified state

#### Scenario: Navigation links resolve to existing routes
- **WHEN** the user triggers navigation from the KYC hub
- **THEN** the app navigates to a registered route and does not dead-end
