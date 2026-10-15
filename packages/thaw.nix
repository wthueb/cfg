{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/thaw-app/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
    hash = "sha256-I/6FDda24/girwCi2nbG1GE1wvqKDe746PoJ0e/T7sE=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -r Thaw.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Menu bar manager for macOS";
    homepage = "https://github.com/thaw-app/Thaw";
    changelog = "https://github.com/thaw-app/Thaw/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
