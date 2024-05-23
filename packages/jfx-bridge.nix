{
  buildPythonPackage,
  fetchPypi,
  substituteAll,
  pip,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "jfx_bridge";
  version = "1.0.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "e291b51f510bd2587619434f94c89f0c805936c492924c0d905e9222fa290729";
  };

  buildInputs = [
    pip
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  patches = [
    (substituteAll {
      src = ./patches/jfx-bridge-setuptools.patch;
      inherit version;
    })
  ];
}
