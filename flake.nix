{
  description = "Typsite Env";
  inputs = {
    typsite.url = "github:Glomzzz/typsite";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      typsite,
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.typst
            typsite.packages.${system}.default
          ];
          # Also expose the project fonts to direct `typst` invocations.
          TYPST_FONT_PATHS = toString ./.typsite/assets/fonts;
        };
      }
    );
}
