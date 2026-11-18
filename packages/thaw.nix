{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "3.0.0-beta.7";

  src = fetchurl {
    url = "https://github.com/thaw-app/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
    hash = "sha256-4TQUtjmkMw7xVWHGw/2S1Bet05m9LY2bjdpOwifEg9I=";
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
