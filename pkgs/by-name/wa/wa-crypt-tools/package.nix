{
  lib,
  python3,
  fetchPypi,
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      protobuf = super.protobuf.overridePythonAttrs (_: rec {
        version = "5.27.5";
        src = fetchPypi {
          pname = "protobuf";
          inherit version;
          hash = "sha256-f6gbxVAgEUSjL0R4ZZ2gbgsuvk1TA6rM6aICocPVF40=";
        };
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "wa-crypt-tools";
  version = "0.1.0";
  pyproject = true;

  src = fetchPypi {
    pname = "wa_crypt_tools";
    inherit version;
    hash = "sha256-E/k2lKxlBxUDnfbeELHBi3sML3T+BQJ3zPHh4hGviJ4=";
  };

  build-system = with python.pkgs; [
    setuptools-scm
  ];

  dependencies = with python.pkgs; [
    javaobj-py3
    pycryptodomex
    # protobuf version expected: <5.28.0,>=5.27.3
    protobuf
  ];

  nativeCheckInputs = with python.pkgs; [
    pytest
  ];

  checkPhase = ''
    pytest tests
  '';

  pythonImportsCheck = [ "wa_crypt_tools" ];

  meta = with lib; {
    description = "Manage WhatsApp .crypt12, .crypt14 and .crypt15 files";
    homepage = "https://github.com/ElDavoo/wa-crypt-tools";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ritiek ];
    platforms = platforms.unix;
  };
}
