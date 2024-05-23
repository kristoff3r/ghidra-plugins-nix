{
  stdenv,
  lib,
  fetchFromGitHub,
  ghidra,
  jdk,
  gradle,
  kotlin,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "ghidra-gameboy-plugin";
  version = "20250309-unstable-2025-03-09";

  src = fetchFromGitHub {
    owner = "Gekkio";
    repo = "GhidraBoy";
    rev = "d899c2a6a364cce46fae664328a73db277c7a3fb";
    sha256 = "sha256-+GiimSg/T66NznJy5XcJheSvXExBpYswkqtXCt2hggE=";
  };

  nativeBuildInputs = [
    jdk
    gradle
    kotlin
  ];

  buildPhase = ''
    # The plugin directory is named by the folder where it gets built -_-
    mkdir ${pname}
    mv * ${pname} || true
    cd ${pname}

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
    description = "Gameboy plugin for Ghidra";
    homepage = "https://github.com/Gekkio/GhidraBoy";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
