{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-cpp-class-analyzer-plugin";
  version = "2022-11-05";

  src = fetchFromGitHub {
    owner = "astrelsky";
    repo = "Ghidra-Cpp-Class-Analyzer";
    rev = "8c48817a4b4c6637db80bbc23ac0e83e2bc29a2b";
    sha256 = "sha256-CwjR9WynYlzQzbI21SrJjZcWVJjkg0HDjB5y5Jm6exI=";
  };

  nativeBuildInputs = [
    jdk
    gradle
  ];

  buildPhase = ''
    GHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra gradle buildExtension --no-daemon
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp dist/*.zip $out/share
    runHook postInstall
  '';

  meta = with lib; {
    description = "C++ Class and Run Time Type Information Analyzer";
    homepage = "https://github.com/astrelsky/Ghidra-Cpp-Class-Analyzer";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
