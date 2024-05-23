{ buildPythonPackage, fetchPypi,

  nix-update-script,
 }:

buildPythonPackage rec {
  pname = "ghidra-stubs";
  version = "11.3.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-BohCOrL6OD9urR87hy+YakUUSZvsfno+HPv9qKBOJno=";
  };

  passthru.updateScript = nix-update-script { };
}
