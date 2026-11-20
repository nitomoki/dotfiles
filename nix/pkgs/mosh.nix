# 私用フォーク（OSC の通し方を選べるようにしたもの）。https://github.com/nitomoki/mosh
{ mosh, fetchFromGitHub }:
let
  tag = "fork-1";
in
mosh.overrideAttrs (old: {
  version = "1.4.0-${tag}";
  src = fetchFromGitHub {
    owner = "nitomoki";
    repo = "mosh";
    inherit tag;
    hash = "sha256-52DaCE2pJ/2AamGTjw1GBAwWERm/9A4FZgy7hVd4wq4=";
  };
  # mosh-client_path.patch は mosh.pl の mosh-client を store のパスに固定するもの。フォークの
  # mosh.pl は同じディレクトリの mosh-client を優先するよう書き換えてあり、パッチが当たらない。
  patches = builtins.filter (p: baseNameOf p != "mosh-client_path.patch") old.patches;
  # `--version` の [build ...] は git describe で決まり、.git の無い store のソースでは
  # PACKAGE_STRING（mosh 1.4.0）に落ちる。Release のバイナリと同じくタグ名を出す。
  postPatch = old.postPatch + ''
    substituteInPlace Makefile.am \
      --replace-fail '@echo @PACKAGE_STRING@ > VERSION.dist' '@echo ${tag} > VERSION.dist'
  '';
})
