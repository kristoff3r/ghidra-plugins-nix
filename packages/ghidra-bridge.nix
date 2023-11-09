{ buildPythonPackage, fetchPypi, substituteAll, pip, jfx-bridge, setuptools }:

buildPythonPackage rec {
  pname = "ghidra_bridge";
  version = "1.0.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "3a7bdf9c8c1dc78acd3e8cfe9649d0e9554e47e147435730104efee634b01c9d";
  };

  doCheck = false;

  buildInputs = [
    pip
  ];

  propagatedBuildInputs = [
    jfx-bridge
    setuptools
  ];

  patches = [
      (substituteAll {
      src = ./ghidra-bridge-setuptools.patch;
      inherit version;
    })
  ];
}