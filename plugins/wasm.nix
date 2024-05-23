{
  stdenv,
  lib,
  fetchFromGitHub,
  ghidra,
  jdk,
  gradle,
  sleigh,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "ghidra-wasm-plugin";
  version = "2.3.1-unstable-2025-01-22";

  src = fetchFromGitHub {
    owner = "nneonneo";
    repo = pname;
    rev = "93532ad5d3033b62236e453be437b7435a0a6d8b";
    sha256 = "sha256-JFUPhh4WUcfxYow3kLMyva1Ni/cQBIit983o/KbbKps=";
  };

  nativeBuildInputs = [
    jdk
    gradle
  ];

  buildPhase = ''
    # The plugin directory is named by the folder where it gets built -_-
    mkdir ${pname}
    mv * ${pname} || true
    cd ${pname}

    # Compile sleigh definitions so Ghidra doesn't crash on runtime
    ${sleigh}/bin/sleigh -a data/languages

    GHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra gradle buildExtension --no-daemon
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp dist/*.zip $out/share

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Module to load WebAssembly files into Ghidra";
    homepage = "https://github.com/nneonneo/ghidra-wasm-plugin";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
