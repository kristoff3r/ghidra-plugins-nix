{ stdenv
, lib
, fetchzip
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "sleigh";
  version = "10.2.3";

  src = fetchzip {
    url = "https://github.com/lifting-bits/sleigh/releases/download/v${version}/Linux-sleigh-${version}-1.x86_64.tar.gz";
    sha256 = "sha256-fWWPs/Gx4+P/yWOtV7JXkRqhhZ5qs7kYDzcc3/CJlk8=";
  };

  nativeBuildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p "$out/bin"
    ls -la
    cp bin/sleigh* $out/bin/
  '';

  meta = with lib; {
    description = "A CMake-based build project for Sleigh so that it can be built and packaged as a standalone library and be reused in projects other than Ghidra.";
    homepage = "https://github.com/lifting-bits/sleigh";
    license = licenses.asl20;
  };
}
