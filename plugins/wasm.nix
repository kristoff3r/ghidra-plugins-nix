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
  version = "2022-04-24";

  src = fetchFromGitHub {
    owner = "kristoff3r";
    repo = pname;
    rev = "8798978d5aebd31edc8cee214a38ffc901808085";
    sha256 = "sha256-eTVyt8jBFCGtj7EHCAWDBS37t963Q4uGfELnKp7+GeA=";
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
