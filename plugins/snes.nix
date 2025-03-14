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
  pname = "ghidra-snes-loader";
  version = "0-unstable-2023-07-13";

  src = fetchFromGitHub {
    owner = "CelestialAmber";
    repo = "ghidra-snes-loader";
    rev = "69fbe4bf43ed1469652a4c5129d6f874268a41d6";
    sha256 = "sha256-/fWb/vVwm0vowaKffRtsdbCYR+wzWiY4HcUYiW6xI/s=";
  };

  nativeBuildInputs = [
    jdk
    gradle
  ];

  buildPhase = ''
    cd SnesLoader
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
    description = "Loader for SNES ROMs";
    homepage = "https://github.com/achan1989/ghidra-snes-loader";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
