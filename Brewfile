# macOS で永続的にインストールしたい Homebrew パッケージのリスト。
# Linux (apt) 側の packages.txt に相当する。
# 共通の CLI ツールは nix/home.nix の home.packages で入れる（make switch）。
# ここに残すのは GUI アプリ・フォントと、Nix の store では動かしにくいもの。
# 新マシンでセットアップ: make packages-install   (= brew bundle install)
# 現在の差分を確認:       make packages-diff

# --- Language runtimes ---
# Rust は rustup で入れる（brew の rust は ~/.cargo/bin の rustup 版を隠すため）。
# node は Nix にしない。store が読み取り専用で npm -g が書けないため。
brew "node"

# --- CLI tools ---
brew "cpanminus"     # Nix の perl だと cpanm が store に書けない
brew "mosh"          # etc/init/mosh.sh の私用フォークが入らなかったときの予備

# --- Fonts ---
cask "font-hackgen-nerd"

# --- GUI apps ---
cask "claude"
cask "claude-code@latest"
cask "obsidian"
cask "wezterm"
cask "tailscale-app"
# cask "steam"
