{
  description = "a ruby-only flake";

  nixConfig = {
    extra-substituters = "https://nixpkgs-ruby.cachix.org";
    extra-trusted-public-keys = "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    ruby-nix.url = "github:inscapist/ruby-nix";

    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        { config, system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.nixpkgs-ruby.overlays.default ];
          };

          # See available versions: https://github.com/bobvanderlinden/nixpkgs-ruby/blob/master/ruby/versions.json
          ruby = pkgs."ruby-3.4.9";
          gemset = if builtins.pathExists ./gemset.nix then import ./gemset.nix else { };
          # See default: https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/ruby-modules/gem-config/default.nix
          extraGemConfig = { };

          inherit
            (
              (inputs.ruby-nix.lib pkgs {
                inherit ruby gemset;
                name = "project-name";
                gemConfig = pkgs.defaultGemConfig // extraGemConfig;
              })
            )
            env
            ;
        in
        {
          devShells.default = pkgs.mkShell {
            BUNDLE_PATH = "vendor/bundle";

            packages = [
              env
              ruby
            ];

            shellHook = ''
              export PATH="$PWD/bin:$PATH"
            '';
          };
        };
    };
}
