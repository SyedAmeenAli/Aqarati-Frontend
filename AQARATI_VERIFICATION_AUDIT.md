# AQARATI Verification Audit

## Trust layers (kept strictly separate, per product spec)

| Layer | Where shown | Status |
|---|---|---|
| Identity verified (personal) | Profile "Account" card, Drawer, auth gate | IMPLEMENTED (mocked backend) |
| Business verified | N/A | NOT YET AVAILABLE — no business-verification flow exists |
| Property verified | Property cards / detail | IMPLEMENTED (pre-existing, unrelated to this session) |

No screen combines these into one generic "Verified" badge.

## Identity verification mechanisms

1. **Email + Phone verification** (onboarding) — MOCKED. Any 6-digit OTP accepted after a simulated delay. No real SMS/email provider.
2. **`IdentityVerificationFlow`** (Profile/Drawer/auth-gate "Verify identity" button) — MOCKED. Generic intro → waiting → success, no external provider. THEQA fully removed (0 references).
3. **Citizenship/residency status** — real frontend state (`CitizenshipStatus` enum), no backend validation.
4. **Passport verification** — capture is UI-only (see onboarding audit); review/submit sets `PassportVerificationState.pending` and never advances past that without a real backend. Never displays "verified" or "government verified" without a real result.

## Service mode / fee / key custody

- `ServiceMode` (Broker / DIY), `kAqaratiServiceFeeRate` (2.0% default, single source of truth in `lib/data/models/verification_models.dart`), `KeyCustodyState` — all real enums, no scattered hard-coded "2%" strings found in a repo-wide search this session.
- Fee shown in: onboarding DIY explanation (`AqaratiFeeCard`), Profile (`_FeeDisclosureCard` + "How it works" sheet), Make Offer screen (live `_FeePreview` computed from the entered offer amount, shown only for DIY users).
- **Not built**: a dedicated Booking Review → Payment → Confirmation checkout pipeline. No such screens exist in the codebase prior to this session (only Book Viewing — free, no money — and Make Offer — a non-binding offer). Building a full fake "payment succeeded" confirmation without a real payment provider would violate the "never fabricate payment success" rule, so this was deliberately not built. The `Payment` data model already exists (pre-existing) but has no screen consuming it yet.
- Key custody: My Home → Key Custody is real (status, demo-labeled timeline, working Return-my-keys flow with confirmation dialog and state progression). Reachable, no dead buttons.

## App review prompt

- `lib/core/widgets/aqarati_review_prompt.dart` — IMPLEMENTED, shows once (SharedPreferences-gated) the first time Home is entered after onboarding has any answer.
- "Leave a review" is honest: this build targets web, so there is no App Store/Play Store to open — it shows a thank-you message and says so, rather than pretending a native review sheet succeeded. No `in_app_review` package was added (native-only, untestable in this session/target).

## Static banned-term audit (this session)

```
grep -rniE "theqa|\bkyc\b|national id|aadhaar|uidai" lib/   -> 0 matches
grep -rniE "\bAED\b|\bUAE\b|\bDubai\b" lib/                  -> 0 matches
```

## Google Sign-In

Pre-existing mock (`lib/features/verification/google_signin_flow.dart`), reachable from Profile and Drawer. Not rewired into the onboarding entry point as a first-class "Continue with Google vs Continue with phone" choice screen, and no account-conflict/dedup logic was added — both require either a real OAuth backend or a larger, riskier rearchitecture of the auth entry that wasn't attempted this pass to avoid inventing backend behavior.
