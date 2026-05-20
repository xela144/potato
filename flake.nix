{
  description = "Portable user environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system}.userland = pkgs.buildEnv {
      name = "userland";
      paths = import ./nix/userland.nix { inherit pkgs; };
    };
  };
}
