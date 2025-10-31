# Rusty Path of Building Nix Package

This repository provides a Nix expression to build [Rusty Path of Building](https://github.com/meehl/rusty-path-of-building).

## Usage (Flake)
```nix
{
  inputs.rusty-pob.url = "github:yourusername/nixos-rusty-path-of-building";

  outputs = { self, nixpkgs, rusty-pob, ... }: {
    packages.x86_64-linux.default = rusty-pob.packages.x86_64-linux.rusty-path-of-building;
  };
}


## Usage (non-Flake)
let
  rustyPOB = import (fetchFromGitHub {
    owner = "yourusername";
    repo = "nixos-rusty-path-of-building";
    rev = "<commit>";
    sha256 = "<hash>";
  }) {};
in
rustyPOB
