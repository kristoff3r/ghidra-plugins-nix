{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-nes-plugin";
  version = "2022-10-08";

  src = fetchFromGitHub {
    owner = "kylewlacy";
    repo = "GhidraNes";
    rev = "136cbb7faa1e75ec42a1b1471100c1c2554eb14a";
    sha256 = "sha256-YeXs+m/gZIV69HqhULO8rUHEX+U7giBJTVlguTRWLBk=";
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

  meta = with lib; {
    description = "A Ghidra extension to support disassembling and analyzing NES ROMs";
    homepage = "https://github.com/kylewlacy/GhidraNes";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
