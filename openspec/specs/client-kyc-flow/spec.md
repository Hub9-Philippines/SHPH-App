# client-kyc-flow Specification

## Purpose

Lets clients verify their identity entirely in-app through a skippable flow of onboarding, government-ID and selfie capture, and camera-based face liveness, submitting to the KYC backend as a customer.

## Requirements

### Requirement: Client KYC flow opens with an onboarding screen
The client KYC flow SHALL open with an onboarding screen stating what the user needs (a valid government ID and a live selfie) and why verification matters, a primary action to start, and a "Skip for now" action.

#### Scenario: Intro states requirements and starts capture
- **WHEN** the user opens the client KYC onboarding screen
- **THEN** the screen lists the required ID and live selfie, offers a primary action to begin, and shows Skip for now

#### Scenario: Skip from intro returns home
- **WHEN** the user chooses "Skip for now" on the intro screen
- **THEN** the app calls the skip-KYC endpoint and routes the user to Home

### Requirement: ID document, selfie, and preview capture
The KYC document screen SHALL let the user capture or upload a government ID (front and back) and a selfie from camera or gallery and SHALL show a preview of each capture; submission SHALL require all three.

#### Scenario: Captures render previews
- **WHEN** the user captures ID front, ID back, and a selfie
- **THEN** each capture shows a preview on the document screen

#### Scenario: Submit gates on all three captures
- **WHEN** any of ID front, ID back, or selfie is missing
- **THEN** the submit action is disabled

### Requirement: Camera-based face liveness against a server challenge
The KYC liveness screen SHALL request a liveness challenge from the backend, guide the user through a live camera capture of their face, and SHALL include the challenge nonce and liveness metadata with the submission; if the challenge endpoint fails, the app SHALL fall back to a local action plan and continue without a nonce.

#### Scenario: Challenge plan drives the capture
- **WHEN** the app requests a liveness challenge and receives a plan
- **THEN** the screen guides the user through the plan with the live camera and submits the capture with the challenge nonce and liveness metadata

#### Scenario: Challenge request fails
- **WHEN** the liveness challenge endpoint is unreachable
- **THEN** the app runs a fallback action plan and submits the capture without a nonce

### Requirement: Client KYC submits with the customer role
The client KYC submission SHALL set the submitter role to the backend's client vocabulary (`customer`) and SHALL send `id_front`, `id_back`, `selfie`, and liveness data to the KYC submit endpoint; the backend remains the single source of verification truth.

#### Scenario: Submission uses the customer role
- **WHEN** the client KYC flow submits documents
- **THEN** the payload's submitter role is `customer` and includes id front, id back, selfie, and liveness fields

#### Scenario: Success routes to Home and never marks local verification
- **WHEN** the client KYC submission succeeds
- **THEN** the app routes the user to Home and does not record verification as complete locally

### Requirement: KYC skip is only offered before first submission
Each client KYC screen SHALL offer "Skip for now", which SHALL call the skip-KYC endpoint and route to Home. Skip MUST NOT be offered when a prior submission is pending or rejected, mirroring the provider deferral rule.

#### Scenario: Skip persists and is not re-forced
- **WHEN** a client skips KYC
- **THEN** the app records the skip via the backend and later sessions do not force the KYC flow again

#### Scenario: Pending or rejected submissions cannot skip
- **WHEN** a client's KYC submission is pending or was rejected
- **THEN** the app does not offer Skip for now and routes them to the KYC flow
