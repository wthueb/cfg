{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_16,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "skhd-zig";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jackielii";
    repo = "skhd.zig";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qi5srrpdhf3VcXaqZbijJD23Um0G7WgRzK0hR+mb7nU=";
  };

  patches = [ ./agent-only.patch ];

  nativeBuildInputs = [ zig_0_16.hook ];
  strictDeps = true;

  doCheck = true;
  zigCheckFlags = [
    "--summary"
    "all"
  ];

  doInstallCheck = true;
  postInstallCheck = ''
    test ! -e "$out/bin/skhd-grabber"
    test ! -e "$out/bin/skhd-alloc"
  '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/skhd";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Simple macOS hotkey daemon written in Zig (without skhd-grabber)";
    homepage = "https://github.com/jackielii/skhd.zig";
    changelog = "https://github.com/jackielii/skhd.zig/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "skhd";
  };
})
