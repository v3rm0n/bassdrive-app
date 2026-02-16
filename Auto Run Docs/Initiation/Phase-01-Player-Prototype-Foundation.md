# Phase 01: Player Prototype Foundation

This phase establishes a distinctive visual foundation and ships a fully working, polished Player-first prototype in the running app, so the user immediately sees a dramatic UI upgrade while preserving all current playback behavior (live + archive) without requiring any decisions during execution.

## Tasks

- [x] Capture baseline and lock implementation constraints for autonomous execution:
  - Read current UI/theme/navigation/player files (`lib/utils/theme.dart`, `lib/widgets/full_player.dart`, `lib/widgets/audio_controls.dart`, `lib/widgets/adaptive_navigation.dart`, `lib/main.dart`)
  - Record a short implementation note in task output with fixed visual direction: "high-contrast broadcast console" (dark-only, cyan-forward, metallic neutrals, strong typography)
  - Confirm no product decisions are needed and proceed with this direction as default
  - Completion note (Loop 00001): Baseline review completed across the five specified files; fixed visual direction is locked as **high-contrast broadcast console** (dark-only, cyan-forward, metallic neutrals, strong typography); no product decisions were required, so execution proceeds with this default.

- [ ] Create the new design foundation and wire it as app default theme:
  - Add a dedicated UI theme layer (tokens for color, type, spacing, radius, elevation, motion) under `lib/ui/theme/`
  - Define component theme extensions for cards, pills, transport controls, and section headers
  - Update app theme wiring in `lib/utils/theme.dart` and `lib/main.dart` to consume the new tokens while keeping dark-mode behavior

- [ ] Build reusable Player UI primitives for the new visual language:
  - Create reusable widgets under `lib/ui/player/` for hero cover, live badge, track meta block, timeline/progress row, and transport cluster
  - Ensure widgets accept current `AudioPlayerService` state and do not duplicate playback logic
  - Keep desktop and mobile sizing behavior in shared primitives to avoid divergent layouts

- [ ] Rebuild `FullPlayer` into a polished, working prototype using the new primitives:
  - Replace generic gradient/card treatment with the new broadcast-console composition (hero, metadata, timeline, controls, ambient motion)
  - Preserve all existing behavior: play/pause toggle, start-live when idle, archive seek slider, stats screen access
  - Add subtle purposeful animations (entry reveal + play-state pulse) with safe performance defaults

- [ ] Integrate prototype-level app chrome consistency around the Player:
  - Refine navigation prominence for Player tab/rail item and active-state styling through shared tokens
  - Harmonize top-level loading/error states in `HomeScreen` with the new visual system so first impression matches the Player redesign
  - Verify no regression in desktop sidebar and mobile bottom navigation flows

- [ ] Produce structured implementation artifacts alongside the code changes:
  - Create `docs/architecture/player-ui-foundation.md` with YAML front matter (`type: reference`, title, created date, tags)
  - Create `docs/decisions/adr-001-player-visual-direction.md` with YAML front matter (`type: analysis`) explaining chosen defaults and tradeoffs
  - Link both docs using wiki-links (`[[player-ui-foundation]]`, `[[adr-001-player-visual-direction]]`)

- [ ] Write focused UI tests for the new Player prototype (separate from execution):
  - Add/extend widget tests to cover idle -> live start behavior, archive progress visibility, and key controls render states
  - Keep tests deterministic by mocking service state transitions instead of relying on network/audio backends

- [ ] Run verification and fix failures until green:
  - Run `flutter analyze`
  - Run targeted and full test suites (`flutter test`)
  - Run the app on one local target and confirm the redesigned Player renders and functions end-to-end
