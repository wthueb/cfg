{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  bun,
}:
let
  pname = "copilot-api";
  version = "0.7.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-NinExhBP7nnv/Sd/UCCgTehwQvJsCZoA/6Rz04fWl/4=";
  };

  nativeBuildInputs = [
    makeWrapper
    bun
  ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    bun install --production --ignore-scripts
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}/

    mkdir -p $out/bin
    makeWrapper ${bun}/bin/bun $out/bin/copilot-api \
      --add-flags "run $out/lib/node_modules/${pname}/dist/main.js"
    runHook postInstall
  '';

  meta = {
    description = "Turn GitHub Copilot into OpenAI/Anthropic API compatible server";
    homepage = "https://github.com/ericc-ch/copilot-api";
    license = lib.licenses.mit;
    mainProgram = "copilot-api";
  };
}
