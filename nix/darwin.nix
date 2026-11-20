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
    # 一覧に無い formula / cask / tap を switch のたびにアンインストールする。cask は
    # zap stanza に従い ~/Library のアプリのデータも消すので、手で brew install した
    # ものを残したいときは先にここへ足す（make packages-diff で消える対象を確かめられる）。
    onActivation.cleanup = "zap";

    brews = [
      "cpanminus" # Nix の perl だと cpanm が store に書けない
    ];

    casks = [
      "claude"
      "claude-code@latest"
      "obsidian"
      "wezterm"
      "tailscale-app"
      "discord"
      "parallels"
    ];
  };
}
