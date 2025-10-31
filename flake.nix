{
  description = "Nix package for rusty-path-of-building";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system}.default = pkgs.callPackage ./default.nix { 
      makeWrapper = pkgs.makeWrapper;
    };
  };
}
