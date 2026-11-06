# v1.0 acceptance checklist

This is a release gate, not a claim of implementation. README claims and static code inspection do not substitute for live-client evidence. Check a box only after its behavior is verified; record test date/client and evidence in this file.

- [ ] Verify sourced Arms/Fury leveling and endgame Protection/Arms/Fury sequences against Icy Veins
- [ ] Replace inferred talent steps with verified progression where possible
- [ ] Live-test C_Traits name/node mapping, level-up popup and point-spent refresh
- [ ] Verify Legacy early points, non-Warrior behavior and Blizzard talent glow
- [ ] Verify weekly source refresh and release packaging

## Evidence

- Code review: 2026-11-05 — inspected talent event lifecycle; committed `8430d23` to preserve dismissed popups across routine trait refreshes and reopen only on a verified rise in unspent currency. No live behavior claimed.
- Automated/static tests: pending (no WoW client simulation or Lua runtime execution performed for this change).
- Live WoW: Forever client verification: pending — specifically dismiss popup, spend a point, open talents, change zones, and earn a new Legacy/level point to verify it reopens only for the new point.
- Release ZIP and WoWUp installation: pending

## Status

Pre-1.0. Features described in README may be implemented but are not accepted as verified here until tested. Avoid declaring v1.0 solely on version metadata.

## Phase 1 — unknown talent currency handling (2026-11-05)

- [x] `Core.lua` `HasUnspentTalentPoint` no longer treats every level-10+ character as having an unspent point when the Forever trait currency API is missing or returns unavailable data (commit `a7c4de2`). Unknown stays unknown; the guide remains accessible manually in the Talent window. No SavedVariables schema changes.
- [ ] Verify on live client that early Legacy points and ordinary level-up points trigger guidance when the currency API is available, and that unavailable currency suppresses false popups without hiding manual guidance. Code inspection only; no Lua runtime or live-client verification.
