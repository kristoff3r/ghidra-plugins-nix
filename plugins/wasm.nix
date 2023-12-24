{ stdenv
, lib
, fetchFromGitHub
, ghidra
, jdk11
, gradle
, sleigh
}:

let
  jdk = jdk11;
in
stdenv.mkDerivation rec {
  pname = "ghidra-wasm-plugin";
  version = "2023-12-24";

  src = fetchFromGitHub {
    owner = "kristoff3r";
    repo = pname;
    rev = "2fbb3cd4af0f85ade324016d11eea6129134db52";
    sha256 = "sha256-4yzKclQ768UMRG5J0W21t8ZynBJbgUbNMBSdveBMsgg=";
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

    # Compile sleigh definitions so Ghidra doesn't crash on runtime
    ${sleigh}/bin/sleigh -a data/languages

    GHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra gradle buildExtension --no-daemon
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp dist/*.zip $out/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "Module to load WebAssembly files into Ghidra";
    homepage = "https://github.com/nneonneo/ghidra-wasm-plugin";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
