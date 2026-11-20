{
  config,
  lib,
  pkgs,
  machine,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  # 配るのは ~/dotfiles の実ファイルへのリンク（mkOutOfStoreSymlink）で、store へのコピーではない。
  # nvim の lazy-lock.json のように配布先で書き換わるファイルがあり、編集を
  # switch なしで効かせたいため。
  # そのため switch はどこで実行しても ~/dotfiles を指す（Makefile の switch が
  # worktree からの実行を断るのはこのため）。
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  link = rel: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${rel}";

  # 一覧は flake の評価元（git に入っているファイル）から取る。未追跡のファイルは配られない。
  src = ./..;

  # 隠しファイル（.gitkeep など）は配らない。
  children =
    rel:
    builtins.filter (n: !lib.hasPrefix "." n) (builtins.attrNames (builtins.readDir (src + "/${rel}")));

  # rel 直下の各エントリを 1 つずつリンクする。サブディレクトリはディレクトリごとリンクする
  # （.claude/skills/<name> はスキルにファイルを足すたびに switch しなくて済む）。
  # rel そのものをリンクしないのは、~/.config/nvim などにアプリが作るファイルが同居するため。
  linkChildren =
    {
      rel,
      to ? rel,
      exclude ? [ ],
    }:
    lib.listToAttrs (
      map (n: lib.nameValuePair "${to}/${n}" { source = link "${rel}/${n}"; }) (
        lib.subtractLists exclude (children rel)
      )
    );

  homeDotfiles = [
    ".gitignore"
    ".latexmkrc"
    ".nethackrc"
    ".zlogin"
    ".zshenv"
    ".zshrc"
  ];

  # .config/systemd は他アプリのユニットが混ざるので、下の systemdUserFiles で個別に扱う。
  # polybar は X11 前提なので macOS には配らない。
  configDirs = lib.subtractLists ([ "systemd" ] ++ lib.optionals isDarwin [ "polybar" ]) (
    children ".config"
  );

  # 環境別の wezterm 設定は wezterm_env.lua という名前でマシンごとに 1 つだけ配る。
  weztermEnvFiles = [
    "wezterm_mac.lua"
    "wezterm_nucbox.lua"
    "wezterm_windows.lua"
    "wezterm_wsl2.lua"
  ];

  systemdUserFiles = [
    ".config/systemd/user/obsidian.service"
    ".config/systemd/user/graphical-session.target.wants/obsidian.service"
  ];

  # .claude/skills_<machine> はそのマシンにだけ配るスキルで、~/.claude/skills へ合流させる
  # ので、ここでは除く。スキルの説明文は全セッションのコンテキストに載るため、使わない
  # マシンには配らない。
  claudeEntries = children ".claude";
  claudeDirs = builtins.filter (
    n: !lib.hasPrefix "skills_" n && (builtins.readDir (src + "/.claude")).${n} == "directory"
  ) claudeEntries;
  claudeFiles = builtins.filter (
    n: (builtins.readDir (src + "/.claude")).${n} != "directory"
  ) claudeEntries;
  machineSkills = ".claude/skills_${machine}";
  hasMachineSkills = builtins.pathExists (src + "/${machineSkills}");

  # settings.json のマージでローカル側の値を残すキー。model / effortLevel は PC ごと、
  # agentPushNotifEnabled / theme は /config でセッションから切り替えるもので、どれも
  # 配布物には持たない。ここに挙げ忘れたキーは switch のたびに消える。
  claudeLocalKeys = "model, effortLevel, agentPushNotifEnabled, theme";
in
{
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  # 既定で入る man-db の man が OS の man を上書きする。
  programs.man.enable = false;

  # ~/.config/nix/nix.conf を生成する。初回の switch はまだこれが無いので、Makefile が
  # --extra-experimental-features を付けて呼ぶ。
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # 共通の CLI ツールとフォント。GUI アプリ、OS に密着したもの（mozc、tailscale、
  # Linux のコンパイラ一式など）は nix/darwin.nix の homebrew / packages.txt に残す。
  # node / perl（cpanm）は残す。Nix の store は読み取り専用で、npm -g や cpanm が
  # 自分の prefix に書き込めないため。
  # markdown-reader は私用フォークが private リポジトリにあり、switch（Mac では root で動く）
  # から取得できないので、etc/init/markdown-reader.sh で ~/.local/bin に入れる。
  home.packages =
    with pkgs;
    [
      bat
      cmake
      eza
      fzf
      gh
      hackgen-nf-font
      jq
      (callPackage ./pkgs/mosh.nix { })
      neovim
      nkf
      pipx
      ripgrep
      sheldon
      silver-searcher-ng # ag。silver-searcher は nixpkgs から削除済み
      tmux
      tree-sitter
      uv
    ]
    ++ lib.optionals isDarwin [
      # gdate / gtimeout（Claude の hook が使う）。接頭辞なしの coreutils は ls や cp を
      # GNU 版で上書きしてしまう。
      coreutils-prefixed
    ];

  # Linux で ~/.local/share/fonts の HackGen を fontconfig に見せる。macOS は home-manager が
  # ~/Library/Fonts/HomeManager にコピーする。
  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nitomoki";
        email = "nitomoki.2@gmail.com";
      };
      # `gh auth setup-git` と同じ設定。gh 自身が書くと gh の絶対パスが焼き込まれ、gh の
      # 入れ方が変わると壊れる（brew 版を消したときに実際に壊れた）。空の値は、OS の
      # git が既定で持つ osxkeychain などを外すため。
      credential = lib.genAttrs [ "https://github.com" "https://gist.github.com" ] (_: {
        helper = [
          ""
          "!${lib.getExe pkgs.gh} auth git-credential"
        ];
      });
    };
  };

  home.file =
    lib.genAttrs homeDotfiles (f: {
      source = link f;
    })
    // lib.mergeAttrsList (
      map (
        d:
        linkChildren {
          rel = ".config/${d}";
          exclude = lib.optionals (d == "wezterm") weztermEnvFiles;
        }
      ) configDirs
    )
    // lib.optionalAttrs (builtins.pathExists (src + "/.config/wezterm/wezterm_${machine}.lua")) {
      ".config/wezterm/wezterm_env.lua".source = link ".config/wezterm/wezterm_${machine}.lua";
    }
    // lib.optionalAttrs isLinux (
      lib.genAttrs systemdUserFiles (f: {
        source = link f;
      })
    )
    # markdown-reader は設定の場所を Rust の dirs::config_dir() で決めるため、macOS では
    # ~/Library/Application Support を読む。
    // lib.optionalAttrs isDarwin {
      "Library/Application Support/markdown-reader/config.toml".source =
        link ".config/markdown-reader/config.toml";
    }
    # .claude のディレクトリは丸ごとリンクせず中身を 1 つずつリンクする。~/.claude/commands
    # などは Claude Code 自身も実ディレクトリとして作るため。
    // lib.genAttrs (map (f: ".claude/${f}") claudeFiles) (f: {
      source = link f;
    })
    // lib.mergeAttrsList (map (d: linkChildren { rel = ".claude/${d}"; }) claudeDirs)
    // lib.optionalAttrs hasMachineSkills (linkChildren {
      rel = machineSkills;
      to = ".claude/skills";
    });

  # GNOME のデスクトップがあるのは Nucbox だけ。WSL2 には GNOME も dconf も無い。
  dconf.settings = lib.mkIf (machine == "nucbox") {
    "org/gnome/shell/extensions/dash-to-dock" = {
      autohide = false;
      dock-fixed = false;
      intellihide = false;
    };
    "org/gnome/libgnomekbd/keyboard".options = [ "ctrl\tctrl:nocaps" ]; # Caps Lock を Ctrl に
    "org/gnome/desktop/interface".gtk-key-theme = "Emacs";
  };

  # ホームのフォルダ名は日本語にせず英語にする（ja_JP のままだと xdg-user-dirs が
  # 「デスクトップ」などを作る）。音楽・画像などは専用のフォルダを作らずホームを指す。
  xdg.userDirs = lib.mkIf (machine == "nucbox") {
    enable = true;
    package = null; # Ubuntu の xdg-user-dirs を使う
    setSessionVariables = false;
    desktop = "${config.home.homeDirectory}/Desktop";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    templates = config.home.homeDirectory;
    publicShare = config.home.homeDirectory;
    music = config.home.homeDirectory;
    pictures = config.home.homeDirectory;
    videos = config.home.homeDirectory;
    projects = null;
  };

  # obsidian.service は GUI セッションで起動させるもの。home-manager にユニットの
  # 起動・再起動を任せると、ssh から switch しただけで Obsidian が立ち上がる。
  systemd.user.startServices = lib.mkIf isLinux false;

  home.activation = {
    # 他マシン専用に移したスキルなど、配布元が消えた古いリンクを掃除する。
    # home-manager が張ったリンクは自分で外すが、以前 ln -s で張ったリンクは残るため。
    claudeSkillsCleanup = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      for l in "$HOME/.claude/skills/"* "$HOME/.claude/skills/".[!.]*; do
        if [ -L "$l" ] && [ ! -e "$l" ]; then
          verboseEcho "unlink $l (リンク切れ)"
          run rm -f "$l"
        fi
      done
    '';

    # ~/.claude/settings.json は symlink にせず、共有設定をローカルの実ファイルへ
    # マージする。/model などの書き込み先がこのファイルなので、symlink にすると
    # dotfiles が汚れる。claudeLocalKeys はローカル側の値を残す。
    # claude/ に置くのは、.claude/ 直下だと dotfiles で作業したときにプロジェクト設定
    # として二重に読まれ、hook が 2 回動くため。
    claudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      settings="$HOME/.claude/settings.json"
      shared="${dotfilesDir}/claude/settings.dotfiles.json"
      run mkdir -p "$HOME/.claude"
      if [ -L "$settings" ]; then run rm -f "$settings"; fi
      if [ ! -f "$settings" ]; then
        run cp "$shared" "$settings"
      else
        if [ -z "''${DRY_RUN:-}" ]; then
          ${lib.getExe pkgs.jq} -s '.[1] + (.[0] | {${claudeLocalKeys}} | with_entries(select(.value != null)))' \
            "$settings" "$shared" > "$settings.tmp" \
            && mv "$settings.tmp" "$settings"
        fi
      fi
    '';

    # sheldon の lock には zsh/*.zsh を展開したファイル一覧が焼き込まれ、lock は
    # plugins.toml が変わったときしか作り直されない。zsh/ にファイルを足しても
    # 読まれないままになる（zsh/tmux.zsh で実際に起きた）ので、毎回作り直す。
    # 既存プラグインまで更新したくないので --update は付けない。
    sheldonLock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if ! out=$(run ${lib.getExe pkgs.sheldon} lock 2>&1); then
        warnEcho "sheldon lock に失敗（既存の lock を保持）: $out"
      fi
    '';
  }
  // lib.optionalAttrs isDarwin {
    # wezterm.lua は term = "wezterm" だが、macOS 版 WezTerm.app は terminfo を同梱せず
    # OS にも無い。未登録だと zsh の行編集（BS・カーソル移動）が壊れる。
    # etc/terminfo/wezterm.terminfo は公式リポジトリの termwiz/data/ から取得したもの。
    weztermTerminfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /usr/bin/tic -x -o "$HOME/.terminfo" "${dotfilesDir}/etc/terminfo/wezterm.terminfo"
    '';
  };
}
