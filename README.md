# ghidra-plugins-nix

Nix derivations for building and configuring Ghidra and Ghidra plugins.

Contributions welcome! I plan to add/update plugins I find useful, extra ways to
configure Ghidra and maybe other reverse engineering tools that are too niche
for nixpkgs.

## Usage

First get Nix with [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes),
then you can start a Ghidra with all current plugins and processors using the following command:

```bash
nix run "github:kristoff3r/ghidra-plugins-nix"
```