---
type: analysis
title: ADR-001 Player Visual Direction
created: 2026-02-16
tags:
  - adr
  - player-ui
  - visual-direction
related:
  - "[[player-ui-foundation]]"
---

# ADR-001: Player Visual Direction

## Status

Accepted.

## Context

Phase 01 needed a visible UI leap centered on the Player experience while preserving existing playback behavior (live + archive) and staying fully executable without follow-up product decisions.

The prior UI implementation was functional but did not establish a strong, reusable visual system for the redesigned player and surrounding app chrome.

## Decision

Adopt a high-contrast broadcast-console direction as the default foundation for the player prototype:

- Dark-only surfaces with cyan-forward emphasis and metallic neutrals.
- Tokenized theming and reusable component extensions as the style source of truth.
- Shared player primitives that read state from `AudioPlayerService` through `PlayerViewState`.
- Lightweight, purposeful motion (entry reveal and play-state pulse) with bounded durations and curves from theme motion tokens.

## Alternatives Considered

### 1) Keep the existing generic card/gradient design

- Pros: lowest implementation cost.
- Cons: limited visual identity, weaker hierarchy, little improvement in first impression.

### 2) Build separate mobile and desktop player variants

- Pros: maximal per-platform tailoring.
- Cons: duplicated logic and styling drift risk; higher maintenance burden.

### 3) Introduce bright/light dual-mode redesign in this phase

- Pros: broader palette coverage.
- Cons: conflicted with current dark-only product behavior and increased scope for this prototype phase.

## Tradeoffs

- **Accepted complexity:** additional token and extension layers increase up-front structure.
- **Mitigated risk:** stronger consistency, easier scaling, and less styling duplication across player/navigation surfaces.
- **Visual specificity vs flexibility:** the broadcast-console style is intentionally opinionated; future phases can still iterate by adjusting shared tokens rather than rewriting widgets.

## Consequences

- Theme and chrome now derive from explicit token and extension contracts.
- Player UI uses reusable primitives and shared layout scaling across device classes.
- Regression and behavior verification benefit from deterministic widget tests around key player states.

## References

- Foundation reference: [[player-ui-foundation]]
- Primary implementation files:
  - `lib/ui/theme/app_theme_tokens.dart`
  - `lib/ui/theme/component_theme_extensions.dart`
  - `lib/ui/player/player_primitives.dart`
  - `lib/widgets/full_player.dart`
