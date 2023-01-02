{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-golang-analyzer-plugin";
  version = "2022-12-20";

  src = fetchFromGitHub {
    owner = "mooncat-greenpy";
    repo = "Ghidra_GolangAnalyzerExtension";
    rev = "0f90a1192e525692fd82f2a346a2bd72ee193f78";
    sha256 = "sha256-CDKnTJLkHs5hnpr3ilx6sUNppxtm2wRiEH9oQBydxOg=";
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
    description = "GolangAnalyzerExtension helps Ghidra parse Golang binaries. It supports both 32bit and 64bit.";
    homepage = "https://github.com/mooncat-greenpy/Ghidra_GolangAnalyzerExtension";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
