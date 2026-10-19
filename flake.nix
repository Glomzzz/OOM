{
  description = "Typsite Env";
  inputs = {
    # Published 0.1.8 release; keep synchronized with CI's TYPSITE_TAG.
    typsite.url = "github:Glomzzz/typsite/0.1.8-55";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
            (pkgs.python3.withPackages (ps: [ ps.fonttools ps.brotli ps.rcssmin ]))
            typsite.packages.${system}.default
          ];
          # Also expose the project fonts to direct `typst` invocations.
          TYPST_FONT_PATHS = toString ./.typsite/assets/fonts;
        };
      }
    );
}
