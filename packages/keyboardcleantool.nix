{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  curl,
  jq,
  nix-update,
  writeShellApplication,
}:
stdenvNoCC.mkDerivation {
  pname = "keyboardcleantool";
  version = "8.3";

  src = fetchurl {
    url = "https://folivora.ai/releases/KeyboardCleanTool-8.3.zip";
    hash = "sha256-E+KgYSIGJjkrJTq0FQCHGsm9obklmNejB3tIOWAlbJM=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    rm -f KeyboardCleanTool.app/Contents/Resources/._rot.png
    mkdir -p $out/Applications
    cp -r KeyboardCleanTool.app $out/Applications/
    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-keyboardcleantool";
    runtimeInputs = [
      curl
      jq
      nix-update
    ];
    text = ''
      version=$(curl --fail --silent --show-error https://formulae.brew.sh/api/cask/keyboardcleantool.json \
        | jq --exit-status --raw-output '.version')
      nix-update --flake --version "$version" keyboardcleantool
    '';
  });

  meta = {
    description = "Blocks all Keyboard and TouchBar input";
    homepage = "https://folivora.ai/keyboardcleantool";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
