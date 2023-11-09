{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "ghidra-stubs";
  version = "10.4.1.0.4";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-BohCOrL6OD9urR87hy+YakUUSZvsfno+HPv9qKBOJno=";
  };
}