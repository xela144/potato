{
  description = "Portable user environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, hunk }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    hunk-pkg = hunk.packages.${system}.default;
  in {
    packages.${system}.userland = pkgs.buildEnv {
      name = "userland";
      paths = import ./nix/userland.nix { inherit pkgs pkgs-unstable hunk-pkg; };
    };
  };
}
