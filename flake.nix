{
  description = "Nix package + NixOS module for Rusty Path of Building";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
    lib = nixpkgs.lib;
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = lib.genAttrs supportedSystems;
  in {
    # -----------------
    # Packages
    # -----------------
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.callPackage ./default.nix { };
      }
    );

    # -----------------
    # NixOS module
    # -----------------
    nixosModules = {
      rusty-path-of-building = { config, lib, pkgs, ... }: with lib; {
        options.rusty-path-of-building.enable =
          mkEnableOption "Enable Rusty Path of Building (PoB in Rust)";

        config = mkIf config.rusty-path-of-building.enable {
          environment.systemPackages = [ self.packages.${pkgs.system}.default ];
        };
      };
    };

    # Optional defaultPackage shortcut
    defaultPackage = forAllSystems (system: self.packages.${system}.default);
  };
}
