{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake"; # https://community.flake.parts/haskell-flake
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [inputs.haskell-flake.flakeModule];

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

        packages.default = self'.packages.skiletro; # haskell-flake doesn't set the default package, but you can do it here.
      };
    };
}
