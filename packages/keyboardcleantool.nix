{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "keyboardcleantool";
  version = "7";

  src = fetchurl {
    url = "https://folivora.ai/releases/KeyboardCleanTool.zip";
    hash = "sha256-nujha0SzBWI0KaODB91muIdL+nTtuFiwQ3rWKs3bdLY=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r KeyboardCleanTool.app $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "Blocks all Keyboard and TouchBar input";
    homepage = "https://folivora.ai/keyboardcleantool";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
