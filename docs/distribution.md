# Multi-Platform Distribution & Signing Guide

All platforms use the unified reverse-domain App / Bundle ID **`io.maido.bassdrive`**.
Every platform builds automatically in [`.github/workflows/release.yml`](../.github/workflows/release.yml) and [`.github/workflows/web.yml`](../.github/workflows/web.yml). Signing and store uploads activate automatically once their repository secrets are added.

---

## 1. Web (PWA on GitHub Pages) — Free, Ready Immediately

1. In GitHub repo **Settings → Pages → Build and deployment**, set **Source** to **GitHub Actions**.
2. Merge to `main` (or trigger **Deploy Web PWA** manually in the Actions tab).
3. The PWA deploys to `https://v3rm0n.github.io/bassdrive-app/`.

**Optional enhancement (live track title in browsers):**
`https://www.bassdrive.com/now-playing.php` does not send CORS headers, so browsers ignore it and fall back to `"Worldwide drum & bass, around the clock"`. To show live track info on Web too, include `"nowPlaying"` in `https://bd.maido.io/api.json` or proxy it from `bd.maido.io` with `Access-Control-Allow-Origin: *`.

---

## 2. Android (Signed APK, Play Store AAB, IzzyOnDroid / F-Droid)

### One-time keystore setup (Free — enables seamless APK upgrades)

Generate a release keystore locally (keep the `.jks` file backed up securely, never commit it):

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Add these 4 repository secrets under **Settings → Secrets and variables → Actions**:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i upload-keystore.jks \| tr -d '\n'` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | Key password |

For local signed builds, copy `android/key.properties.example` to `android/key.properties` and fill in your values.

### Distribution channels
- **GitHub Releases + Obtainium**: Works automatically with `app-release.apk` once the keystore secrets are added.
- **IzzyOnDroid / F-Droid** (Free): Open a submission issue in IzzyOnDroid pointing to your GitHub Releases APK, or submit an `io.maido.bassdrive.yml` recipe to `fdroiddata`.
- **Google Play Store** ($25 one-time): Create an app with package `io.maido.bassdrive` and upload `app-release.aab` from the GitHub Release. Note that new personal Play accounts require a **12-tester, 14-day continuous closed test** before production access.

---

## 3. Windows (Installer, Microsoft Store MSIX, Winget)

Every release builds three Windows artifacts automatically:
- `Bassdrive-Radio-Windows-Setup.exe` (Inno Setup installer — Start Menu shortcut, clean upgrades, no admin prompt needed)
- `Bassdrive-Radio-Windows.msix` (Microsoft Store / MSIX package)
- `Bassdrive-Radio-Windows.zip` (portable archive)

### Microsoft Store ($0 Free — removes SmartScreen warnings automatically)
1. Register a free individual developer account at [Microsoft Partner Center](https://partner.microsoft.com/dashboard) (ID verification only, no credit card).
2. Reserve the app name **Bassdrive Radio** and note your **Package/Identity/Name** and **Package/Identity/Publisher** (`CN=...`) from **Product management → Product Identity**.
3. Add two GitHub secrets so CI builds a Store-ready MSIX automatically:
   - `WINDOWS_STORE_IDENTITY_NAME`
   - `WINDOWS_STORE_PUBLISHER`
4. Upload `Bassdrive-Radio-Windows.msix` to Partner Center. Microsoft code-signs it on publication.

### Winget (Free CLI installs: `winget install ...`)
1. After tagging a release containing `Bassdrive-Radio-Windows-Setup.exe`, create your initial manifest in [`microsoft/winget-pkgs`](https://github.com/microsoft/winget-pkgs) using `wingetcreate new <installer-url>`.
2. Once merged, set repository variable `WINGET_PACKAGE_ID` (e.g. `Maido.BassdriveRadio`) and secret `WINGET_TOKEN` (a GitHub PAT with `public_repo` scope) so future tags submit Winget PRs automatically.

---

## 4. Linux (AppImage, `.deb`, Flathub Flatpak)

Every release builds:
- `Bassdrive-Radio-Linux.AppImage` (single executable, runs on most distros)
- `Bassdrive-Radio-Linux.deb` (Debian / Ubuntu package with `libmpv` dependency and desktop launcher)
- `Bassdrive-Radio-Linux.tar.gz` (portable tarball)

### Flathub (Free — shows up in GNOME Software & KDE Discover)
1. Update the release tag URL and `sha256` (from `SHA256SUMS.txt`) in [`packaging/linux/io.maido.bassdrive.yml`](../packaging/linux/io.maido.bassdrive.yml).
2. Verify domain control for `io.maido.bassdrive` per Flathub's instructions (DNS TXT record or `https://maido.io/.well-known/org.flathub.VerifiedApps.txt`).
3. Submit a PR to [`flathub/flathub`](https://github.com/flathub/flathub) with `io.maido.bassdrive.yml`, `io.maido.bassdrive.desktop`, and `io.maido.bassdrive.metainfo.xml`.

---

## 5. macOS (Notarized DMG + Homebrew Cask) — Once Apple Developer is Approved

### Enable signing & notarization in CI
1. In Apple Developer Portal, create a **Developer ID Application** certificate, export it from Keychain Access as `.p12`, and create an app-specific password at [account.apple.com](https://account.apple.com).
2. Add these repository secrets:

| Secret | Value |
|---|---|
| `MACOS_CERTIFICATE_P12` | `base64 -i developer-id.p12 \| tr -d '\n'` |
| `MACOS_CERTIFICATE_PASSWORD` | `.p12` export password |
| `MACOS_SIGNING_IDENTITY` | e.g. `Developer ID Application: Your Name (TEAMID)` |
| `APPLE_ID` | Your Apple ID email |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for `notarytool` |
| `APPLE_TEAM_ID` | 10-character Apple Team ID |

### Homebrew Cask (Free one-command installs)
1. Create a repo named `v3rm0n/homebrew-tap` and copy [`packaging/macos/bassdrive-radio.rb`](../packaging/macos/bassdrive-radio.rb) to `Casks/bassdrive-radio.rb`.
2. Update `version` and `sha256` from the release's `SHA256SUMS.txt`. Users can then install via:
   ```bash
   brew tap v3rm0n/tap
   brew install --cask bassdrive-radio
   ```

---

## 6. iOS & iPadOS (TestFlight + App Store) — Same Apple Developer Account

1. In Apple Developer Portal:
   - Register App ID `io.maido.bassdrive`.
   - Create an **Apple Distribution** certificate (export as `.p12`).
   - Create an **App Store Connect** provisioning profile for `io.maido.bassdrive` (download `.mobileprovision`).
2. In App Store Connect:
   - Create the app **Bassdrive Radio** with bundle ID `io.maido.bassdrive`.
   - Under **Users and Access → Integrations → App Store Connect API**, create a key with **App Manager** role (download the `.p8` file, note the **Key ID** and **Issuer ID**).
3. Add these repository secrets:

| Secret | Value |
|---|---|
| `IOS_CERTIFICATE_P12` | `base64 -i ios-dist.p12 \| tr -d '\n'` |
| `IOS_CERTIFICATE_PASSWORD` | `.p12` export password |
| `IOS_PROVISIONING_PROFILE` | `base64 -i profile.mobileprovision \| tr -d '\n'` |
| `APPLE_TEAM_ID` | Same 10-character Apple Team ID as macOS |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | API Issuer ID |
| `APP_STORE_CONNECT_API_KEY_P8` | `base64 -i AuthKey_XXXX.p8 \| tr -d '\n'` |

Once set, every `vX.Y.Z` tag builds a signed `.ipa` and uploads it directly to TestFlight.
