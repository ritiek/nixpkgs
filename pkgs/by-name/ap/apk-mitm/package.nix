{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  fixup-yarn-lock,
  yarn,
  nodejs,
}:

stdenv.mkDerivation rec {
  pname = "apk-mitm";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "niklashigi";
    repo = "apk-mitm";
    rev = "v${version}";
    hash = "sha256-+WZbs10+id+nohTZzLjEofb6k8PMGd73YhY3FUTXx5Q=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-++MqWIUntXQwOYpgAJ3nhAtZ5nxmEreioVHQokYkw7w=";
  };

  nativeBuildInputs = [
    makeWrapper
    fixup-yarn-lock
    yarn
  ];

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror "$offlineCache"
    fixup-yarn-lock yarn.lock
    yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    yarn --offline --production install

    mkdir -p "$out/lib/node_modules/apk-mitm"
    cp -r . "$out/lib/node_modules/apk-mitm"

    makeWrapper "${nodejs}/bin/node" "$out/bin/apk-mitm" \
      --add-flags "$out/lib/node_modules/apk-mitm/bin/apk-mitm"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A CLI application that automatically prepares Android APK files for HTTPS inspection";
    homepage = "https://github.com/niklashigi/apk-mitm";
    license = licenses.mit;
    mainProgram = "apk-mitm";
    maintainers = with maintainers; [ ritiek ];
    platforms = platforms.all;
  };
}
