{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;

        plugins = {
          nes = pkgs.callPackage ./plugins/nes.nix { ghidra = ghidra-bin; };
          wasm = pkgs.callPackage ./plugins/wasm.nix {
            inherit sleigh;
            ghidra = ghidra-bin;
          };
        };

        sleigh = pkgs.callPackage ./packages/sleigh.nix { };
        ghidra-wrapped = ghidra: { plugins, processors}: ghidra.overrideAttrs (attrs:
          let
            pluginDir = pkgs.symlinkJoin { name = "ghidra-plugins"; paths = plugins; };
            processorsDir = pkgs.symlinkJoin { name = "ghidra-processors"; paths = processors; };
          in
        {
          preFixup = (attrs.preFixup or "") + ''
            pushd $out/lib/ghidra/Ghidra/Extensions
              for p in ${pluginDir}/share/*.zip; do
                ${pkgs.unzip}/bin/unzip "$p"
              done
            popd

            pushd $out/lib/ghidra/Ghidra/Processors
              for p in ${processorsDir}/share/*; do
                cp -r $p .
              done
            popd

            ${pkgs.python3.withPackages(ps: [ghidra-bridge])}/bin/python3 -m ghidra_bridge.install_server \
              $out/lib/ghidra/Ghidra/Features/Python/ghidra_scripts
          '';
        });

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
          ghidra-all-plugins = ghidra-with-plugins { inherit plugins; processors = []; };
          ghidra-bin-with-plugins = ghidra-wrapped ghidra-bin;
          ghidra-bin-all-plugins = ghidra-bin-with-plugins { inherit plugins; processors = []; };

          # Python packages
          inherit ghidra-stubs ghidra-bridge jfx-bridge;
        };

        checks = {
          inherit (packages) ghidra-bin-all-plugins ghidra-stubs ghidra-bridge;
          # TODO: broken
          # inherit (packages) ghidra-all-plugins;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.jdk
            pkgs.gradle
            ghidra-bin
            ghidra-bridge
          ];

          GHIDRA_INSTALL_DIR="${ghidra-bin}/lib/ghidra";
        };
      }
    );
}
