# AQARATI Onboarding Audit

Last updated: this session (post THEQA-removal / email-phone-OTP / broker-DIY / key-custody rework).

## Step inventory (`lib/features/onboarding/onboarding_flow.dart`)

Order is computed dynamically (`_order` getter) — later branches depend on earlier answers.

| Step | Status | Applies to |
|---|---|---|
| Splash (video) | IMPLEMENTED | everyone |
| Language | IMPLEMENTED | everyone |
| Location permission | IMPLEMENTED (mock geolocation, no real device permission call) | everyone |
| Email address | IMPLEMENTED (frontend validation only) | everyone |
| Email OTP | MOCKED — any 6-digit code verifies after a fixed delay, no real email sent | everyone |
| Phone number | IMPLEMENTED (frontend validation, +968 fixed) | everyone |
| Phone OTP | MOCKED — same as email OTP | everyone |
| Full name | IMPLEMENTED | everyone |
| Intro / Who are you (role) | IMPLEMENTED | everyone |
| Transaction / Property type / Services | IMPLEMENTED (pre-existing) | everyone |
| Service mode (Broker vs DIY) | IMPLEMENTED | buyer/tenant role only (`isConsumerFlow`) |
| Service mode explanation + fee card | IMPLEMENTED | consumer flow, DIY branch shows live `AqaratiFeeCard` |
| Owner journey | IMPLEMENTED | consumer flow |
| Key deposit intro/consent/details/handover/confirmation | IMPLEMENTED (frontend state machine, demo handover locations explicitly labeled) | consumer flow, owner-side + Broker only |
| Citizenship status | IMPLEMENTED | consumer flow |
| Passport intro | IMPLEMENTED | consumer flow |
| Passport capture | **MOCKED — UI only.** "Take photo" / "Upload from phone" both just flip a local `_captured` flag. No `image_picker`/`camera` package integrated. NOT YET AVAILABLE as a real capture. | consumer flow, if not skipped |
| Passport review | IMPLEMENTED (checklist UI), submits to mock pending state | consumer flow |
| Verification pending | IMPLEMENTED — stops honestly at "pending", never claims verified | consumer flow |
| Location / Budget / Summary / Completion | IMPLEMENTED (pre-existing) | everyone |

## Professional branch behavior (audited this session)

Real Estate Agent / Construction / Property Development / Architecture / Interior Design / Exterior Design roles:
- **DO** go through email verification, phone verification, and full name — these sit in the fixed prefix of `_order`, before role selection, so no role can bypass them.
- **DO NOT** go through service mode, owner journey, key deposit, citizenship status, or passport verification — those are consumer-transaction-specific (buying/renting/leasing a home) and conceptually belong to a separate, not-yet-built **business verification** layer (per the identity/business/property trust-layer separation).

This is a deliberate scope boundary, not an accidental bypass: personal identity verification (email+phone, always) is never merged with business verification (not yet implemented).

## NOT YET AVAILABLE / explicitly deferred

- Real Arabic translations. RTL layout mirroring works (verified: language screen flips fully on selecting Arabic), but no ARB/localization pipeline exists — every string in the app, old and new, is hard-coded English. Building this properly needs a real translator, not machine translation (which the product spec explicitly forbids).
- Real passport camera capture (needs `image_picker`/`camera` package + native permission handling + device testing not possible in this build/session).
- Google Sign-In remains the pre-existing mock (`GoogleSignInFlow`) — a real OAuth flow needs a configured Google Cloud OAuth client + backend session handling, which does not exist and was not invented.
- Full 5-breakpoint × (light/dark) × (English/Arabic) screenshot matrix was not completed. A partial live-render check was done at 360×800 (language step) via a local debug build; further interactive step-through was blocked by browser-automation click-reliability issues against the local `flutter run` debug server this session (documented flakiness in this environment), not by a demonstrated app defect.
