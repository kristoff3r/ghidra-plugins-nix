{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "ghidra-irisc-processor";
  version = "0-unstable-2024-10-15";

  src = fetchFromGitHub {
    owner = "irisc-research-syndicate";
    repo = "ghidra-processor";
    rev = "4c488a43cdbcef957519e3800c3ba796712d3abb";
    sha256 = "sha256-bFnuTMFYzQjngEjBblQsIU7pHmoMhgapw8mUzAT3USs=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/IRISC
    cp -r . $out/share/IRISC
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Ghidra processor module for the IRISC architecture";
    homepage = "https://github.com/irisc-research-syndicate/ghidra-processor";
    platforms = platforms.linux;
  };
}
