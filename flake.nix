{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;
      in
      {
        packages = rec {
          plugins = {
            nes = pkgs.callPackage ./plugins/nes.nix { inherit ghidra; };
            cpp-analyzer = pkgs.callPackage ./plugins/cpp-analyzer.nix { inherit ghidra; };
            golang-analyzer = pkgs.callPackage ./plugins/golang-analyzer.nix { inherit ghidra; };
            ghostrings = pkgs.callPackage ./plugins/ghostrings.nix { inherit ghidra; };
            # wasm = pkgs.callPackage ./plugins/wasm.nix {};
          };
          ghidra = pkgs.callPackage ./ghidra.nix { };
          ghidra-with-plugins = pkgs.callPackage ./ghidra.nix {
            plugins = with plugins; [
              nes
              cpp-analyzer
              ghostrings
              golang-analyzer
            ];
          };
        };
      }
    );
}
