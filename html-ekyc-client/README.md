# SHPH client eKYC HTML reference

Standalone, light-theme reference screens for the Flutter client eKYC flow. Open `index.html` to start. These pages are a UI prototype only: file selection and liveness progress are simulated and no KYC data is sent to the API.

`status.html` documents every value currently returned by `POST /api/kyc/status/`: `pending`, `resubmitted`, `interview_scheduled`, `interview_passed`, `approved`, `rejected_fixable`, `rejected_fatal`, and legacy `rejected`.
