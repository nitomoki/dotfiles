{ ... }:
{
  system.stateVersion = 6;
  system.primaryUser = "tomoki";
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Nix 本体は公式インストーラが入れたものをそのまま使う。nix-darwin に任せると
  # /etc/nix/nix.conf と nix-daemon の launchd 設定を作り直すことになり、初回の switch で
  # 既存ファイルの退避が要る。flakes の有効化は home-manager の ~/.config/nix/nix.conf で足りる。
  nix.enable = false;

  # 既定で有効な programs.zsh / programs.bash は /etc/zshrc や /etc/bashrc などを生成し、
  # Nix インストーラが追記した同じファイルと衝突する。PATH は ~/.zshenv で組んでいるので
  # nix-darwin には /etc のシェル設定を触らせない。
  programs.zsh.enable = false;
  programs.bash.enable = false;

  users.users.tomoki.home = "/Users/tomoki";

  # 実際に入れるのは Homebrew（nix-darwin は Brewfile を生成して brew bundle を呼ぶだけ）。
  # Homebrew 本体は https://brew.sh のインストーラで入れておく。
  homebrew = {
    enable = true;
    # "zap" にすると一覧に無い formula / cask を消す。一覧に載せていない cask
    # （discord、parallels）が入っているので、載せるか決めるまでは消さない。
    onActivation.cleanup = "none";

    brews = [
      # Rust は rustup で入れる（brew の rust は ~/.cargo/bin の rustup 版を隠すため）。
      # node は Nix にしない。store が読み取り専用で npm -g が書けないため。
      "node"
      "cpanminus" # Nix の perl だと cpanm が store に書けない
      "mosh" # etc/init/mosh.sh の私用フォークが入らなかったときの予備
    ];

    casks = [
      "font-hackgen-nerd"
      "claude"
      "claude-code@latest"
      "obsidian"
      "wezterm"
      "tailscale-app"
    ];
  };
}
