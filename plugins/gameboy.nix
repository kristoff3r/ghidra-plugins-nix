{
  stdenv,
  lib,
  fetchFromGitHub,
  ghidra,
  jdk,
  gradle,
  kotlin,
}:

stdenv.mkDerivation rec {
  pname = "ghidra-gameboy-plugin";
  version = "2024-09-29";

  src = fetchFromGitHub {
    owner = "Gekkio";
    repo = "GhidraBoy";
    rev = "9100c3a2b711e0e6f708e2fea1e8ba32da557e13";
    sha256 = "sha256-1VHoG+iEcq7DswNS8n3z5rxxZdlgKcKzMYxo4o4g+DY=";
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

  meta = with lib; {
    description = "Gameboy plugin for Ghidra";
    homepage = "https://github.com/Gekkio/GhidraBoy";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
