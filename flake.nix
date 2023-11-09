{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;
        mkPluginDir = ps: pkgs.symlinkJoin {
          name = "ghidra-plugins";
          paths = ps;
        };
        plugins = {
          nes = pkgs.callPackage ./plugins/nes.nix { ghidra = ghidra-bin; };
          wasm = pkgs.callPackage ./plugins/wasm.nix {
            inherit sleigh;
            ghidra = ghidra-bin;
          };
          # TODO: commented out plugins are broken in Ghidra 10.3+
          # cpp-analyzer = pkgs.callPackage ./plugins/cpp-analyzer.nix { ghidra = ghidra-bin; };
          # golang-analyzer = pkgs.callPackage ./plugins/golang-analyzer.nix { ghidra = ghidra-bin; };
          # ghostrings = pkgs.callPackage ./plugins/ghostrings.nix { ghidra = ghidra-bin; };
        };
        sleigh = pkgs.callPackage ./packages/sleigh.nix { };
        ghidra-wrapped = ghidra: f: ghidra.overrideAttrs (attrs: {
          preFixup = (attrs.preFixup or "") + ''
            cd $out/lib/ghidra/Ghidra/Extensions
            for p in ${mkPluginDir (f plugins)}/share/*.zip; do
              ${pkgs.unzip}/bin/unzip "$p"
            done

            ${pkgs.python3.withPackages(ps: [ghidra-bridge])}/bin/python3 -m ghidra_bridge.install_server \
              $out/lib/ghidra/Ghidra/Features/Python/ghidra_scripts
          '';
        });
        toList = lib.attrsets.mapAttrsToList (_: p: p);

        ghidra = pkgs.callPackage ./ghidra/build.nix { };
        ghidra-bin = pkgs.callPackage ./ghidra { };

        ghidra-stubs = pkgs.callPackage ./packages/ghidra-stubs.nix { inherit (pkgs.python3Packages) buildPythonPackage; };
        jfx-bridge = pkgs.callPackage ./packages/jfx-bridge.nix { inherit (pkgs.python3Packages) buildPythonPackage pip; };
        ghidra-bridge = pkgs.callPackage ./packages/ghidra-bridge.nix {
          inherit (pkgs.python3Packages) buildPythonPackage pip setuptools;
          inherit jfx-bridge;
        };
      in
      rec {
        packages = flake-utils.lib.flattenTree rec {
          # Ghidra versions
          default = ghidra-bin-all-plugins;
          inherit plugins sleigh ghidra ghidra-bin;

          ghidra-with-plugins = ghidra-wrapped ghidra;
          ghidra-all-plugins = ghidra-with-plugins toList;
          ghidra-bin-with-plugins = ghidra-wrapped ghidra-bin;
          ghidra-bin-all-plugins = ghidra-bin-with-plugins toList;

          # Python packages
          inherit ghidra-stubs ghidra-bridge jfx-bridge;
        };

        checks = {
          inherit (packages) ghidra-all-plugins ghidra-bin-all-plugins ghidra-stubs ghidra-bridge;
        };
      }
    );
}
