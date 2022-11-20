{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-wasm-plugin";
  version = "2021-08-19";

  src = fetchFromGitHub {
    owner = "garrettgu10";
    repo = pname;
    rev = "ac7893c30cad4fe48cffa62aa632a98ebf9c7e66";
    sha256 = "sha256-prncawt6x+niPijLKrOYqRzf0osPOowZpMYpdRmAaIc=";
  };

  nativeBuildInputs = [
    jdk
    gradle
  ];

  buildPhase = ''
    GHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra gradle buildExtension
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp dist/*.zip $out/share
    runHook postInstall
  '';

  meta = with lib; {
    description = "Module to load WebAssembly files into Ghidra";
    homepage = "https://github.com/garrettgu10/ghidra-wasm-plugin";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}