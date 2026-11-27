# Homebrew Cask template for a personal tap (e.g. github.com/v3rm0n/homebrew-tap).
# Place at Casks/bassdrive-radio.rb in your tap repo and update version + sha256
# on each release (or automate updates from GitHub Actions).
cask "bassdrive-radio" do
  version "0.3.0"
  sha256 "REPLACE_WITH_DMG_SHA256"

  url "https://github.com/v3rm0n/bassdrive-app/releases/download/v#{version}/Bassdrive-Radio-macOS.dmg"
  name "Bassdrive Radio"
  desc "Stream Bassdrive 24/7 Drum & Bass radio and archived shows"
  homepage "https://github.com/v3rm0n/bassdrive-app"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Bassdrive Radio.app"

  zap trash: [
    "~/Library/Application Support/io.maido.bassdrive",
    "~/Library/Caches/io.maido.bassdrive",
    "~/Library/Containers/io.maido.bassdrive",
    "~/Library/Preferences/io.maido.bassdrive.plist",
  ]
end
