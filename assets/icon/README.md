# Creating Your App Icon

## Step 1: Create the Icon Files

You need to create two PNG files:

### 1. `icon.png` (1024x1024 pixels)
This is the main app icon. Design suggestions:
- **Background**: Dark gradient (#121212 to #1E1E1E) or solid #121212
- **Foreground**: Cyan (#00BCD4) radio wave or vinyl record design
- **Style**: Simple, bold, recognizable at small sizes

### 2. `icon_foreground.png` (1024x1024 pixels)
This is the foreground layer for Android adaptive icons:
- **Background**: Transparent
- **Foreground**: Just the icon design (radio waves, vinyl, etc.)
- **Safe Zone**: Keep main content within 66% of center (Android crops edges)

## Step 2: Design Ideas

### Option A: Radio Waves
```
    )))  (((
   )))) ((((
  ))))  ((((  
```
Cyan sound waves emanating from center

### Option B: Vinyl Record
- Black vinyl disc with cyan label
- White/cyan "B" or "BD" text
- Subtle groove lines

### Option C: Equalizer Bars
```
  | | | | |
  | | | | |
  | | | | |
```
Vertical bars in cyan/teal gradient

### Option D: Headphones
- Stylized headphones with bass waves
- Cyan color on dark background

## Step 3: Generate Icons

Once you have your icon files:

```bash
# Install dependencies
dart pub get

# Generate icons
dart run flutter_launcher_icons:main
```

This will:
- Generate all Android icon sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Generate all iOS icon sizes (20, 29, 40, 60, 76, 83.5, 1024)
- Update Android manifest
- Update iOS Assets.xcassets

## Step 4: Verify

After generation, check:
- `android/app/src/main/res/mipmap-*/` - Android icons
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` - iOS icons

## Tools for Creating Icons

### Design Tools:
- **Figma** (free) - Best for vector design
- **Adobe Illustrator** - Professional vector
- **Canva** - Simple online design
- **Sketch** (Mac) - UI design

### Online Generators:
- [IconKitchen](https://icon.kitchen/) - Create and preview adaptive icons
- [AppIcon.co](https://appicon.co/) - Generate all sizes from one image
- [MakeAppIcon](https://makeappicon.com/) - Another generator

## Current Status

The app currently uses default Flutter icons. To update:

1. Create `assets/icon/icon.png` (1024x1024)
2. Create `assets/icon/icon_foreground.png` (1024x1024, transparent bg)
3. Run `dart run flutter_launcher_icons:main`
4. Build and test on device

## Color Palette Reference

- Primary: #00BCD4 (Cyan)
- Secondary: #0097A7 (Teal)
- Background: #121212 (Dark)
- Surface: #1E1E1E (Dark Gray)

Use these colors for consistent branding!