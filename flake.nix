{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake"; # https://community.flake.parts/haskell-flake
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          self',
          pkgs,
          lib,
          ...
        }:
        {
          packages.default = pkgs.stdenvNoCC.mkDerivation {
            name = "website";
            src = ./src;

            GIT_REVISION = if (self ? shortRev) then self.shortRev else "dirty";
            # LANG and LOCALE_ARCHIVE are fixes pulled from the community:
            #   https://github.com/jaspervdj/hakyll/issues/614#issuecomment-411520691
            #   https://github.com/NixOS/nix/issues/318#issuecomment-52986702
            #   https://github.com/MaxDaten/brutal-recipes/blob/source/default.nix#L24
            LANG = "en_GB.UTF-8";
            LOCALE_ARCHIVE = pkgs.lib.optionalString (
              pkgs.buildPlatform.libc == "glibc"
            ) "${pkgs.glibcLocales}/lib/locale/locale-archive";

            buildPhase = ''
              ${lib.getExe self'.packages.ssg} build --verbose
            '';

            installPhase = ''
              mkdir -p $out/dist
              cp -a _site/. $out/dist
            '';
          };

          haskellProjects.default = {
            projectRoot = ./ssg;
            devShell = {
              enable = true;
              tools = hp: { inherit (hp) hakyll; };
              hlsCheck.enable = true;
              mkShellArgs = {
                buildInputs = with pkgs; [
                  just
                  sass
                ];
                shellHook = "just -l -u";
              };
            };
          };

          treefmt = {
            flakeCheck = true;
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              just.enable = true;
              prettier.enable = true;
              stylish-haskell.enable = true;
            };
          };
        };
    };
}
