# Phase 01: Player Prototype Foundation

This phase establishes a distinctive visual foundation and ships a fully working, polished Player-first prototype in the running app, so the user immediately sees a dramatic UI upgrade while preserving all current playback behavior (live + archive) without requiring any decisions during execution.

## Tasks

- [x] Capture baseline and lock implementation constraints for autonomous execution:
  - Read current UI/theme/navigation/player files (`lib/utils/theme.dart`, `lib/widgets/full_player.dart`, `lib/widgets/audio_controls.dart`, `lib/widgets/adaptive_navigation.dart`, `lib/main.dart`)
  - Record a short implementation note in task output with fixed visual direction: "high-contrast broadcast console" (dark-only, cyan-forward, metallic neutrals, strong typography)
  - Confirm no product decisions are needed and proceed with this direction as default
  - Completion note (Loop 00001): Baseline review completed across the five specified files; fixed visual direction is locked as **high-contrast broadcast console** (dark-only, cyan-forward, metallic neutrals, strong typography); no product decisions were required, so execution proceeds with this default.

- [x] Create the new design foundation and wire it as app default theme:
  - Add a dedicated UI theme layer (tokens for color, type, spacing, radius, elevation, motion) under `lib/ui/theme/`
  - Define component theme extensions for cards, pills, transport controls, and section headers
  - Update app theme wiring in `lib/utils/theme.dart` and `lib/main.dart` to consume the new tokens while keeping dark-mode behavior
  - Completion note (Loop 00001): Added `lib/ui/theme/app_theme_tokens.dart` for broadcast-console design tokens and `lib/ui/theme/component_theme_extensions.dart` for reusable component extensions; rewired `lib/utils/theme.dart` to consume tokenized color/typography/motion and register extensions; updated `lib/main.dart` to force dark-only theme via `themeMode` + `darkTheme`.

- [x] Build reusable Player UI primitives for the new visual language:
  - Create reusable widgets under `lib/ui/player/` for hero cover, live badge, track meta block, timeline/progress row, and transport cluster
  - Ensure widgets accept current `AudioPlayerService` state and do not duplicate playback logic
  - Keep desktop and mobile sizing behavior in shared primitives to avoid divergent layouts
  - Completion note (Loop 00001): Added reusable primitives under `lib/ui/player/` (`player_hero_cover.dart`, `live_badge.dart`, `track_meta_block.dart`, `timeline_progress_row.dart`, `transport_cluster.dart`) plus shared `PlayerViewState.fromService(...)` and `PlayerLayoutScale.fromWidth(...)` so UI reads current `AudioPlayerService` state without embedding playback logic while preserving mobile/desktop sizing from one source of truth; added widget tests in `test/ui/player/player_primitives_test.dart`.

- [x] Rebuild `FullPlayer` into a polished, working prototype using the new primitives:
  - Replace generic gradient/card treatment with the new broadcast-console composition (hero, metadata, timeline, controls, ambient motion)
  - Preserve all existing behavior: play/pause toggle, start-live when idle, archive seek slider, stats screen access
  - Add subtle purposeful animations (entry reveal + play-state pulse) with safe performance defaults
  - Completion note (Loop 00001): Rebuilt `lib/widgets/full_player.dart` around the shared `lib/ui/player/` primitives with a new broadcast-console composition (ambient background, hero, metadata block, timeline row, transport cluster), preserved all existing playback interactions (idle -> live start, play/pause toggle, archive seek + skip, stats screen access), and added lightweight entry reveal + play-state pulse animations; added widget coverage in `test/widgets/full_player_test.dart` for idle live-start and archive timeline/control rendering.

- [x] Integrate prototype-level app chrome consistency around the Player:
  - Refine navigation prominence for Player tab/rail item and active-state styling through shared tokens
  - Harmonize top-level loading/error states in `HomeScreen` with the new visual system so first impression matches the Player redesign
  - Verify no regression in desktop sidebar and mobile bottom navigation flows
  - Completion note (Loop 00001): Updated `lib/widgets/adaptive_navigation.dart` to apply tokenized broadcast-console chrome across desktop rail and mobile navigation, including stronger Player prominence and active-state styling via the new `NavigationChromeTheme`; updated `lib/main.dart` to route both desktop/mobile navigation through `AdaptiveNavigation` and replaced plain loading/error scaffolds with themed console status surfaces; added regression coverage in `test/widgets/app_chrome_test.dart` for loading/error chrome and adaptive navigation interaction.

- [x] Produce structured implementation artifacts alongside the code changes:
  - Create `docs/architecture/player-ui-foundation.md` with YAML front matter (`type: reference`, title, created date, tags)
  - Create `docs/decisions/adr-001-player-visual-direction.md` with YAML front matter (`type: analysis`) explaining chosen defaults and tradeoffs
  - Link both docs using wiki-links (`[[player-ui-foundation]]`, `[[adr-001-player-visual-direction]]`)
  - Completion note (Loop 00001): Added `docs/architecture/player-ui-foundation.md` and `docs/decisions/adr-001-player-visual-direction.md` with required YAML front matter metadata, documented the broadcast-console foundation and decision tradeoffs, and cross-linked both artifacts with `[[player-ui-foundation]]` and `[[adr-001-player-visual-direction]]`.

- [x] Write focused UI tests for the new Player prototype (separate from execution):
  - Add/extend widget tests to cover idle -> live start behavior, archive progress visibility, and key controls render states
  - Keep tests deterministic by mocking service state transitions instead of relying on network/audio backends
  - Completion note (Loop 00001): Extended `test/widgets/full_player_test.dart` with deterministic service-backed widget coverage for archive progress labels (`12:00`/`58:00`), primary transport control state rendering (loading spinner, play icon, pause icon), and loaded-content play toggle behavior that asserts `togglePlayPause()` is used instead of live-start; all coverage relies on mocked `AudioPlayerService` state transitions only (no network/audio backend).

- [ ] Run verification and fix failures until green:
  - Run `flutter analyze`
  - Run targeted and full test suites (`flutter test`)
  - Run the app on one local target and confirm the redesigned Player renders and functions end-to-end
  - Status note (Loop 00001): Re-attempted `flutter analyze`, `flutter test`, and `flutter run -d macos --release`; all fail immediately with `flutter: command not found` in this environment, so verification remains blocked until Flutter SDK/CLI is installed on PATH.
  - Status note (Loop 00001, Maestro): Re-ran `flutter analyze`, `flutter test`, and `flutter run -d macos --release` from `/Users/maidok/Developer/bassdrive-app`; each command still fails with `zsh:1: command not found: flutter`, so no verification fixes can be applied until Flutter is installed and available on PATH.
  - Status note (Loop 00001, Maestro retry): Re-executed `flutter analyze`, `flutter test`, and `flutter run -d macos --release`; all three commands still fail instantly with `zsh:1: command not found: flutter`, so this verification task remains blocked and cannot be checked off until Flutter is installed on PATH.
  - Status note (Loop 00001, Maestro retry 2): Executed `flutter analyze`, `flutter test`, and `flutter run -d macos --release` again on branch `main`; each command continues to fail with `zsh:1: command not found: flutter`, so verification cannot proceed and this checkbox remains open until Flutter CLI is installed on PATH.
