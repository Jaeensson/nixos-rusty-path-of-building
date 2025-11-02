# Rusty Path of Building Nix Package

This repository provides a Nix expression to build [Rusty Path of Building](https://github.com/meehl/rusty-path-of-building).

## Usage example (Flake)
```nix
{
  pob ={
      url =  "github:jaeensson/nixos-rusty-path-of-building";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  outputs = inputs @ {
    self,
    nixpkgs,
    pob,
    ...
  }: 
  {
    nixosConfigurations = {
      nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";

        modules = [
          pob.nixosModules.rusty-path-of-building
        ];
      };
    };
  };
}
```
Then add 

``` nix
rusty-path-of-building.enable = true;
```
To your nix configuration
