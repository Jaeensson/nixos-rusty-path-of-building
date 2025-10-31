{
  description = "Nix package + NixOS module for Rusty Path of Building";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    # Package for each system
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.callPackage ./default.nix { };
      }
    );

    nixosModules.rusty-path-of-building = { config, lib, pkgs, ... }: {
      options.rusty-path-of-building.enable = lib.mkEnableOption "Rusty Path of Building";

      config = lib.mkIf config.rusty-path-of-building.enable {
        environment.systemPackages = [ self.packages.${pkgs.system}.default ];
      };
    };
    # Optional shortcuts
    defaultPackage = forAllSystems (system: self.packages.${system}.default);
  };
}
