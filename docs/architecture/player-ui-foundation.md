---
type: reference
title: Player UI Foundation
created: 2026-02-16
tags:
  - player-ui
  - architecture
  - design-system
related:
  - "[[adr-001-player-visual-direction]]"
---

# Player UI Foundation

This reference captures the shipped Phase 01 player foundation for the Bassdrive app and documents how the new high-contrast broadcast-console system is structured.

## Design Intent

- Visual direction: high-contrast broadcast console.
- Dark-only baseline with cyan-forward accents and metallic neutral surfaces.
- Strong typographic hierarchy to emphasize transport state and currently playing content.

## Theme Token Layer

Core token definitions live in `lib/ui/theme/app_theme_tokens.dart` and provide:

- Color primitives (`AppColors`) for background, surfaces, outlines, text, status, and glow.
- Spatial scale (`AppSpacing`, `AppRadii`) for consistent rhythm and silhouette.
- Elevation and motion primitives (`AppElevation`, `AppMotion`) for restrained but purposeful depth and animation.
- Typeface mapping (`AppTypography`) using Orbitron, Rajdhani, and Space Mono for display/body/labels.

## Component Extensions

Reusable visual contracts are defined in `lib/ui/theme/component_theme_extensions.dart` and registered on the app theme:

- `BroadcastCardTheme`
- `BroadcastPillTheme`
- `TransportControlTheme`
- `SectionHeaderTheme`
- `NavigationChromeTheme`

These extensions prevent hard-coded styling in widgets and keep player, navigation chrome, and status surfaces on one visual system.

## Player Primitive Architecture

The prototype player UI composes reusable primitives from `lib/ui/player/`:

- `PlayerHeroCover`
- `LiveBadge`
- `TrackMetaBlock`
- `TimelineProgressRow`
- `TransportCluster`
- `PlayerLayoutScale`
- `PlayerViewState`

State and interaction source of truth remains `AudioPlayerService`; primitives consume derived `PlayerViewState` without embedding playback business logic.

## Integration Points

- `lib/utils/theme.dart`: maps token and extension values into `ThemeData`.
- `lib/main.dart`: enforces dark theme usage and wires shared app chrome surfaces.
- `lib/widgets/full_player.dart`: uses primitives plus ambient motion while preserving existing play/pause, idle-to-live, seek, and stats navigation behavior.
- `lib/widgets/adaptive_navigation.dart`: applies shared navigation chrome tokens across desktop and mobile.

## Validation Coverage

Current widget coverage tied to this foundation includes:

- `test/ui/player/player_primitives_test.dart`
- `test/widgets/full_player_test.dart`
- `test/widgets/app_chrome_test.dart`

See also [[adr-001-player-visual-direction]] for decision rationale and tradeoffs.
