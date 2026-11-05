# Forever Talent Guide

A small **World of Warcraft: Forever** Warrior addon that answers one question:

> I leveled up. Where does my talent point go?

The addon shows a slim next-point strip inside the top header of Blizzard's Talent window and outlines the recommended talent with a thin gold border, without replacing its icon.

## v0.1.8 scope

- Warrior only.
- Five selectable Warrior profiles:
  - **Leveling - Fury**
  - **Leveling - Arms** (Icy Veins milestones; inferred intermediate points explicitly marked)
  - **Level 60 DPS - Fury**
  - **Level 60 DPS - Arms** (Icy Veins 32/17/2 Mortal Strike)
  - **Level 60 Tank - Protection**
- Icy Veins is the editorial source of truth.
- Next-point guidance stays inside the Talent window, including early Legacy Talented points.
- If the unspent-point API is unavailable, conservatively suppress pre-level-10 popups and only estimate eligibility from level 10 onward.
- The guide is hidden when Talents is closed; opening Talents always displays the current or upcoming rank.
- No chat spam during normal play.
- No automatic talent purchasing.
- Talent nodes are resolved from the live `C_Traits` tree by talent name instead of hard-coded node IDs.
- `/ftg` opens the guide.
- `/ftg leveling`
- `/ftg dps`
- `/ftg arms` (Arms leveling)
- `/ftg armsdps` (Arms level-60 DPS)
- `/ftg tank`
- `/ftg status`
- `/ftg source`
- `/ftg on`
- `/ftg off`

## Guide fidelity and coverage

Both Fury and Arms leveling profiles now provide levels 10–60. Fury uses Icy Veins' November 3 milestones for levels 10–40 and 50–52; gaps in the static guide are filled with clearly flagged approximate recommendations rather than leaving the addon silent. The Arms leveling profile uses the Icy Veins Arms page updated November 3, 2026. The site describes the major level-specific milestones but does not expose every intermediate point as static text. Where we inferred a rank order between explicit milestones, the addon marks it as approximate. These inferred steps are **not** a verbatim Icy Veins export.

The Arms level-60 PvE profile uses Icy Veins' exact **32/17/2** Mortal Strike allocation. Its point-spending order is arranged for a level-60 respec, rather than asserted as Icy Veins' leveling progression.

## Source policy

Build recommendations come from Icy Veins' WoW Forever Warrior guides:

- Fury leveling:
  https://www.icy-veins.com/wow-forever/fury-warrior-leveling
- Fury level-60 PvE talents:
  https://www.icy-veins.com/wow-forever/fury-warrior-melee-dps-pve-spec-builds-talents
- Arms leveling:
  https://www.icy-veins.com/wow-forever/arms-warrior-leveling
- Arms level-60 PvE talents:
  https://www.icy-veins.com/wow-forever/arms-warrior-melee-dps-pve-spec-builds-talents
- Protection level-60 PvE talents:
  https://www.icy-veins.com/wow-forever/protection-warrior-tank-pve-spec-builds-talents

The build data lives in `Builds.lua`, separate from addon logic. That means a weekly guide refresh can update build recommendations without changing `Core.lua` or `UI.lua`.

## Tuesday update policy

The intended maintenance rule is:

1. Check the relevant Icy Veins Warrior guide pages every Tuesday.
2. Compare their current recommended talents/build split against `Builds.lua`.
3. If Icy Veins changed the recommendation, update `Builds.lua`.
4. Bump the addon patch version.
5. Publish a GitHub release so WowUp can see it.
6. If nothing changed, publish nothing.

This is deliberately **not** performed from inside WoW. WoW addons cannot fetch arbitrary websites during play.

## Installation

Copy the `ForeverTalentGuide` folder into the WoW Forever AddOns folder, then enable **Forever Talent Guide** on the character select AddOns screen.

Interface target: `16001`.

## Launch testing checklist

WoW Forever launches November 4, 2026, so v0.1 needs live-client verification.

Check:

- Addon loads without Lua errors.
- Warrior talent tree resolves talent names correctly.
- Level-up event displays the next-point popup.
- Spending the recommended talent immediately advances/hides the recommendation.
- Recommended talent glows in the Blizzard talent window.
- The talent UI frame path is correct in the launch client.
- Legacy `Talented` bonus points do not break the step order.
- Non-Warrior characters load cleanly and receive no popup.

## Design rule

This addon is a guide, not an automation bot. It tells you where the point goes and highlights it. You still click the talent yourself.

## Talent window integration (v0.1.7)

The old floating popup is removed. Open Talents (default N) to see a compact guide in its upper header band; the guide hides with the window. The Build button expands a temporary, attached five-profile selector. The next talent is outlined in gold without using the action-button overlay atlas that rendered a black/yellow square on Improved Rend. No chat spam or automatic talent spending.

## Compact header layout (v0.1.8)

The guide is a single 37-unit-high line in the otherwise empty band immediately below the Primary/Secondary tabs. It anchors to both sides of the talent canvas with a generous right inset so it does not obscure the Unspent Talents counter. The build/source, upcoming talent rank, and Build selector are visible inline. Hovering over the strip shows the former secondary note (estimated order, level milestone, or missing talent). This removes the previous overlap with the tabs and preserves normal Blizzard controls.
