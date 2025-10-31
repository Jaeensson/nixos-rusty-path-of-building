{
  description = "Nix package for Rusty Path of Building";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
      f (import nixpkgs { inherit system; })
    );
  in {
    packages = forAllSystems (pkgs: {
      default = pkgs.callPackage ./default.nix {};
    });

    # optional: allows `nix run` or `nix build`
    defaultPackage = self.packages.x86_64-linux.default;

    # optional: allows `nix develop` if you want dev shell support
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [ pkgs.cargo pkgs.rustc ];
      };
    });
  };
}