{
  description = "nitomoki の dotfiles（home-manager で Mac / Linux の両方に配る）";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      # 名前は Makefile の MACHINE と揃える（.claude/skills_<machine>/ と
      # .config/wezterm/wezterm_<machine>.lua の選択に使う）。
      machines = {
        mac = {
          system = "aarch64-darwin";
          homeDirectory = "/Users/tomoki";
        };
        nucbox = {
          system = "x86_64-linux";
          homeDirectory = "/home/tomoki";
        };
        wsl2 = {
          system = "x86_64-linux";
          homeDirectory = "/home/tomoki";
        };
      };

      mkHome =
        machine:
        { system, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit machine; };
          modules = [
            ./nix/home.nix
            {
              home.username = "tomoki";
              home.homeDirectory = homeDirectory;
            }
          ];
        };

      systems = nixpkgs.lib.unique (nixpkgs.lib.mapAttrsToList (_: m: m.system) machines);
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      homeConfigurations = nixpkgs.lib.mapAttrs mkHome machines;

      # 初回は home-manager コマンドが無いので `nix run .#home-manager` で呼ぶ。
      # flake.lock で固定した版を使うため、nixpkgs の home-manager は使わない。
      packages = forAllSystems (system: {
        home-manager = home-manager.packages.${system}.default;
        default = home-manager.packages.${system}.default;
      });

      # `nix flake check --all-systems` は全 system の checks を評価し、手元の system の分だけ
      # ビルドする。Mac で走らせても Linux 側の設定の評価エラーは拾える（make nix-check）。
      # --all-systems を付けないと、他の system の分は評価もされない。
      checks = forAllSystems (
        system:
        nixpkgs.lib.mapAttrs (name: hm: hm.activationPackage) (
          nixpkgs.lib.filterAttrs (name: _: machines.${name}.system == system) (
            nixpkgs.lib.mapAttrs mkHome machines
          )
        )
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
