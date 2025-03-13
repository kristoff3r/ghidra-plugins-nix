{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        plugins = [
          # (pkgs.callPackage ./plugins/gameboy.nix { })
          (pkgs.callPackage ./plugins/nes.nix { })
          (pkgs.callPackage ./plugins/snes.nix { })
          (pkgs.callPackage ./plugins/wasm.nix { inherit sleigh; })
        ];

        processors = [
          (pkgs.callPackage ./processors/irisc.nix { })
        ];

        sleigh = pkgs.callPackage ./packages/sleigh.nix { };
        ghidra-wrapped =
          ghidra:
          { plugins, processors }:
          ghidra.overrideAttrs (
            attrs:
            let
              pluginDir = pkgs.symlinkJoin {
                name = "ghidra-plugins";
                paths = plugins;
              };
              processorsDir = pkgs.symlinkJoin {
                name = "ghidra-processors";
                paths = processors;
              };
            in
            {
              preFixup =
                (attrs.preFixup or "")
                + ''
                  pushd $out/lib/ghidra/Ghidra/Extensions
                    for p in ${pluginDir}/share/*.zip; do
                      ${pkgs.unzip}/bin/unzip "$p"
                    done
                  popd

                  pushd $out/lib/ghidra/Ghidra/Processors
                    for p in ${processorsDir}/share/*; do
                      ln -s $p .
                    done
                  popd

                  ${pkgs.python3.withPackages (ps: [ ghidra-bridge ])}/bin/python3 -m ghidra_bridge.install_server \
                    $out/lib/ghidra/Ghidra/Features/Python/ghidra_scripts
                '';
            }
          );

        ghidra-stubs = pkgs.callPackage ./packages/ghidra-stubs.nix {
          inherit (pkgs.python3Packages) buildPythonPackage;
        };
        jfx-bridge = pkgs.callPackage ./packages/jfx-bridge.nix {
          inherit (pkgs.python3Packages) buildPythonPackage pip;
        };
        ghidra-bridge = pkgs.callPackage ./packages/ghidra-bridge.nix {
          inherit (pkgs.python3Packages) buildPythonPackage pip setuptools;
          inherit jfx-bridge;
        };
      in
      rec {
        inherit plugins;

        checks = packages;

        packages = rec {
          inherit
            sleigh
            ghidra-stubs
            ghidra-bridge
            jfx-bridge
            ;
          default = ghidra-bin-all-plugins;
          ghidra-bin-all-plugins = (ghidra-wrapped pkgs.ghidra-bin) {
            inherit plugins processors;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.jdk
            pkgs.gradle
            pkgs.ghidra-bin
          ];

          GHIDRA_INSTALL_DIR = "${pkgs.ghidra-bin}/lib/ghidra";
        };
      }
    );
}
