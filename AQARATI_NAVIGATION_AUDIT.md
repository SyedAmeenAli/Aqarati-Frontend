# AQARATI Navigation Audit

## Onboarding stepper

All new steps (email → name, service mode → key custody, citizenship → verification pending) live inside the single `OnboardingFlow` stepper, not as separate `go_router` routes. Back/forward use the existing `_back()`/`_next()` functions against a dynamically-computed `_order` list, so:
- Back always returns to the step the user actually came from (branch-aware — e.g. skipping key deposit means Back from Citizenship Status returns to Owner Journey, not to a hidden key-deposit step).
- No circular traps: `_order` is a linear list per current answer-state; `_back`/`_next` just move ±1 index.
- No orphan steps: every `_Step` enum case has a `_buildStep()` case and appears in `_order` under some condition.

## New standalone routes

- `KeyCustodyScreen` — pushed via `MaterialPageRoute` from My Home, standard AppBar back button, no bottom-nav bleed.
- No other new top-level routes were added this session (Google auth, fee sheet, and review prompt are all modals/sheets on existing screens, not new routes).

## Returning users

`CurrentUserNotifier` persists sign-in to `SharedPreferences` (pre-existing). A returning signed-in user is not re-routed through `OnboardingFlow` — the app's root route only sends first-time/guest sessions there. This was not changed this session.

## Verified this session

- `flutter analyze`: clean (only 9 pre-existing deprecation infos unrelated to this session's changes).
- `flutter build web --release`: succeeds.
- Live render check at 360×800: Language step renders correctly (full-bleed image, no overflow), and tapping the Arabic option correctly mirrors the entire layout to RTL (Skip moves to top-left, checkbox moves to the leading edge, text right-aligns) — a real, observed interaction, not a code-only inference.

## Not completed this session

- Full click-through of every new onboarding/verification screen via the automated browser. The local `flutter run -d chrome` debug session encountered a repeatedly-unresponsive "Continue"/"Skip" tap after the first couple of screens; root cause was not conclusively isolated within the session's tooling (Flutter web's "Enable accessibility" full-screen overlay button was confirmed and dismissed as one contributing factor, but tapping still did not advance afterward). This is reported honestly as **not verified**, rather than claimed as passing — it may be an artifact of this session's debug/DDC build and browser-automation harness rather than a real product defect, since the same button pattern (`_OnboardingScaffold`'s Continue) was used successfully throughout this app already. Recommend the user manually click through once on the deployed Vercel build to confirm.
