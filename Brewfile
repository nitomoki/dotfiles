# macOS で永続的にインストールしたい Homebrew パッケージのリスト。
# Linux (apt) 側の packages.txt に相当する。
# 新マシンでセットアップ: make packages-install   (= brew bundle install)
# 現在の差分を確認:       make packages-diff

# --- Build & dev base ---
brew "cmake"
brew "coreutils"     # gdate / gtimeout など GNU 版（hook のフォールバック用）
brew "git"
brew "jq"            # make deploy の settings.json マージに必須

# --- Language runtimes ---
# Rust は rustup で入れる（brew の rust は ~/.cargo/bin の rustup 版を隠すため）。
brew "node"
brew "pipx"
brew "uv"

# --- Editors / shell ---
brew "neovim"
brew "sheldon"       # zsh プラグインマネージャ
brew "tree-sitter-cli"  # nvim-treesitter (main) の parser ビルドに必須

# --- CLI tools ---
brew "bat"
brew "cpanminus"
brew "eza"
brew "fzf"           # tmux-sessionizer のピッカー
brew "gh"
brew "mosh"
brew "nkf"
brew "ripgrep"
brew "the_silver_searcher"
brew "tmux"

# --- Fonts ---
cask "font-hackgen-nerd"

# --- GUI apps ---
cask "claude"
cask "claude-code@latest"
cask "obsidian"
cask "wezterm"
# cask "tailscale-app"
# cask "steam"
