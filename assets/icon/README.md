# App icon

The icon is the speaker from the player (`lib/ui/player/speaker_cone.dart`):
an amp-yellow dust cap in a dark cone, on the aubergine booth panel.

It is drawn in code by `tool/app_icon/render_icon.swift`. Edit that file, then
regenerate every platform's icon (macOS only, needs ImageMagick):

```bash
tool/app_icon/generate.sh
```

`icon.png` and `icon_foreground.png` here are generated inputs for
`flutter_launcher_icons` (iOS and Android). macOS, Windows and web icons are
written directly, since macOS needs its own squircle shape with margin and
shadow that a resized square can't provide.
