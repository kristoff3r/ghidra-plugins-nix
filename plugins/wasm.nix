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
  version = "2023-05-26";

  src = fetchFromGitHub {
    owner = "kristoff3r";
    repo = pname;
    rev = "05c3a5d7b990cf84665c6a31596b07bfb5fbe6ee";
    sha256 = "sha256-nv6K92byXebHuEus40mfJ2hXOXq20HcGsMBDaxlfMpM=";
  };
  # src = /home/kris/git/ghidra-wasm-plugin;

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
