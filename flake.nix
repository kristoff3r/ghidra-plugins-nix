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
        mkPluginDir = ps: pkgs.symlinkJoin {
          name = "ghidra-plugins";
          paths = ps;
        };
        plugins = with pkgs; {
          nes = callPackage ./plugins/nes.nix { ghidra = ghidra-bin; };
          cpp-analyzer = callPackage ./plugins/cpp-analyzer.nix { ghidra = ghidra-bin; };
          golang-analyzer = callPackage ./plugins/golang-analyzer.nix { ghidra = ghidra-bin; };
          ghostrings = callPackage ./plugins/ghostrings.nix { ghidra = ghidra-bin; };
          wasm = callPackage ./plugins/wasm.nix {
            inherit sleigh;
            ghidra = ghidra-bin;
          };
        };
        sleigh = pkgs.callPackage ./sleigh.nix { };
        ghidra-wrapped = ghidra: f: ghidra.overrideAttrs (attrs: {
          preFixup = (attrs.preFixup or "") + ''
            cd $out/lib/ghidra/Ghidra/Extensions
            for p in ${mkPluginDir (f plugins)}/share/*.zip; do
              ${pkgs.unzip}/bin/unzip "$p"
            done
          '';
        });
        toList = lib.attrsets.mapAttrsToList (_: p: p);
      in
      {
        packages = rec {
          inherit plugins sleigh;

          ghidra-with-plugins = ghidra-wrapped pkgs.ghidra;
          ghidra-all-plugins = ghidra-with-plugins toList;

          ghidra-bin-with-plugins = ghidra-wrapped pkgs.ghidra-bin;
          ghidra-bin-all-plugins = ghidra-bin-with-plugins toList;
        };
      }
    );
}
