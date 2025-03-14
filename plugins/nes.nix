{
  stdenv,
  lib,
  fetchFromGitHub,
  ghidra,
  jdk,
  gradle,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "ghidra-nes-plugin";
  version = "20240311-unstable-2024-03-11";

  src = fetchFromGitHub {
    owner = "kylewlacy";
    repo = "GhidraNes";
    rev = "00d4fc58d230f120afb96a8454eca2c82c4ef2b5";
    sha256 = "sha256-P9SyQO0GI6VAutplxKvQhUWGylMRfASrBrXCxWlZGiA=";
  };

  nativeBuildInputs = [
    jdk
    gradle
  ];

  buildPhase = ''
    cd GhidraNes
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
    description = "A Ghidra extension to support disassembling and analyzing NES ROMs";
    homepage = "https://github.com/kylewlacy/GhidraNes";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
