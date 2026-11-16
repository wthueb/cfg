{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "3.0.0-alpha.14";

  src = fetchurl {
    url = "https://github.com/thaw-app/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
    hash = "sha256-09yXC9Vc1E6ToSX7k7UkrU1LGZza5RFj9l2ECa442v4=";
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
