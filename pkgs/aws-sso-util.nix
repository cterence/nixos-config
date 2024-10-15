{
  lib,
  fetchPypi,
  python3Packages,
}:
let
  aws-error-utils = python3Packages.buildPythonPackage rec {
    pname = "aws-error-utils";
    version = "2.7.0";
    pyproject = true;

    src = fetchPypi {
      pname = "aws_error_utils";
      inherit version;
      hash = "sha256-BxB68qLCZwbNlSW3/77UPy0HtQ0n45+ekVbBGy6ZPJc=";
    };

    build-system = [
      python3Packages.poetry-core
    ];

    dependencies = with python3Packages; [
      botocore
    ];

    pythonImportsCheck = [
      "aws_error_utils"
    ];

    meta = {
      description = "Error-handling functions for boto3/botocore";
      homepage = "https://pypi.org/project/aws-error-utils/";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ cterence ];
      mainProgram = "aws-error-utils";
    };
  };
  aws-sso-lib = python3Packages.buildPythonPackage rec {
    pname = "aws-sso-lib";
    version = "1.14.0";
    pyproject = true;

    src = fetchPypi {
      pname = "aws_sso_lib";
      inherit version;
      hash = "sha256-sCA6ZMy2a6ePme89DrZpr/57wyP2q5yqyX81whoDzqU=";
    };

    build-system = [
      python3Packages.poetry-core
    ];

    dependencies = [
      aws-error-utils
      python3Packages.boto3
    ];

    pythonImportsCheck = [
      "aws_sso_lib"
    ];

    meta = {
      description = "Library to make AWS SSO easier";
      homepage = "https://pypi.org/project/aws-sso-lib/";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ cterence ];
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "aws-sso-util";
  version = "4.33.0";
  pyproject = true;

  src = fetchPypi {
    pname = "aws_sso_util";
    inherit version;
    hash = "sha256-5I1/WRFENFDSjhrBYT+BuaoVursbIFW0Ux34fbQ6Cd8=";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = with python3Packages; [
    aws-error-utils
    aws-sso-lib
    boto3
    click
    jsonschema
    python-dateutil
    pyyaml
    requests
  ];

  pythonImportsCheck = [
    "aws_sso_util"
  ];

  meta = {
    description = "Utilities to make AWS SSO easier";
    homepage = "https://pypi.org/project/aws-sso-util/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cterence ];
    mainProgram = "aws-sso-util";
  };
}
