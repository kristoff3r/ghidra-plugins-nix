# ghidra-plugins-nix

Nix derivations for building and configuring Ghidra and Ghidra plugins.

Contributions welcome! I plan to add/update plugins I find useful, extra ways to
configure Ghidra and maybe other reverse engineering tools that are too niche
for nixpkgs.

## Usage

First get Nix with [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes),
then you can start a Ghidra with all current plugins using the following command:

```bash
nix run "github:kristoff3r/ghidra-plugins-nix"
```
You can also add it with only the plugins you need to a NixOS configuration or a custom flake enviroment, for example:

```nix
{
  description = "Ghidra environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ghidra-plugins.url = "github:kristoff3r/ghidra-plugins-nix";
  };

  outputs = { self, nixpkgs, flake-utils, ghidra-plugins }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ghidra-pkgs = ghidra-plugins.packages.${system};
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [
                (ghidra-pkgs.ghidra-bin-with-plugins (ps: with ps; [
                    wasm
                    nes
                ]))
            ];
          };
        }
      );
}
```

Then the environment can be entered using `nix develop`.

Note that this flake has both `ghidra` and `ghidra-bin` variants. They should be
equivalent except for build time, and sometimes one is updated in nixpkgs before
the other. I recommend using `ghidra-bin` as it load significantly faster.