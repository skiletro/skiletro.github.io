{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake"; # https://community.flake.parts/haskell-flake
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = {
        self',
        pkgs,
        ...
      }: {
        haskellProjects.default = {
          devShell = {
            enable = true;
            tools = hp: {inherit (hp) hakyll;};
            hlsCheck.enable = true;
            mkShellArgs = {
              buildInputs = with pkgs; [just sass];
              shellHook = "just -l -u";
            };
          };
        };

        treefmt = {
          flakeCheck = true;
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            just.enable = true;
            prettier.enable = true;
            stylish-haskell.enable = true;
          };
        };

        packages.default = self'.packages.skiletro; # haskell-flake doesn't set the default package, but you can do it here.
      };
    };
}
