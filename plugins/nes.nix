{ stdenv, lib, fetchFromGitHub, ghidra, jdk11, gradle }:

let
  jdk = jdk11;
in
stdenv.mkDerivation {
  pname = "ghidra-nes-plugin";
  version = "2023-05-27";

  src = fetchFromGitHub {
    owner = "kylewlacy";
    repo = "GhidraNes";
    rev = "ef27b8dd40ca61e43f7f97542690761bb7cf2c2c";
    sha256 = "sha256-AfJcBZfxIfcFLZFD1X9EHOEEJxW8LPmiKJnd8Y50WaE=";
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
