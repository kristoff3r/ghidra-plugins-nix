{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-ghostrings-plugin";
  version = "2022-10-20";

  src = fetchFromGitHub {
    owner = "nccgroup";
    repo = "ghostrings";
    rev = "34d970a6ea61cc82ba1f4feab365b64b4ed3dee0";
    sha256 = "sha256-gfYLQkBbEvhjEaXYZFhlB7ieaFEOBtYOsxpL3PL36Fk=";
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

    GHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra gradle buildExtension --no-daemon
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp dist/*.zip $out/share
    runHook postInstall
  '';

  meta = with lib; {
    description = "Scripts for recovering string definitions in Go binaries with P-Code analysis. Tested with x86, x86-64, ARM, and ARM64.";
    homepage = "https://github.com/nccgroup/ghostrings";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
