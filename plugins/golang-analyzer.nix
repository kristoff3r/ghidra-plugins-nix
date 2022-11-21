{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-golang-analyzer-plugin";
  version = "2022-10-20";

  src = fetchFromGitHub {
    owner = "kristoff3r";
    repo = "Ghidra_GolangAnalyzerExtension";
    rev = "d7476b435269ae27573337620f995b0e2d828fff";
    sha256 = "sha256-1KzaOK9japniv67WhC4tkOzj/QVjJIG4/TF5TYxB498=";
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
