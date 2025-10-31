{
  description = "Nix package + NixOS module for Rusty Path of Building";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # Regular package output
    packages.${system}.default = pkgs.callPackage ./default.nix { };

    # --- NEW: NixOS module ---
    nixosModules.rusty-path-of-building = { config, lib, pkgs, ... }: {
      options.rusty-path-of-building.enable = lib.mkEnableOption "Rusty Path of Building";

      config = lib.mkIf config.rusty-path-of-building.enable {
        environment.systemPackages = [ self.packages.${pkgs.system}.default ];
      };
    };
    
    # Optional: flake `defaultPackage` shortcut
    defaultPackage.${system} = self.packages.${system}.default;
  };
}
