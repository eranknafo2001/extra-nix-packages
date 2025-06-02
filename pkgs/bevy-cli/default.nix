{
  pkgs,
  lib,
}:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bevy-cli";
  version = "cli-v0.1.0-alpha.1";

  src = pkgs.fetchFromGitHub {
    owner = "TheBevyFlock";
    repo = "bevy_cli";
    tag = finalAttrs.version;
    hash = "sha256-v7BcmrG3/Ep+W5GkyKRD1kJ1nUxpxYlGGW3SNKh0U+8=";
  };

  cargoHash = "sha256-QrW0daIjuFQ6Khl+3sTKM0FPGz6lMiRXw0RKXGZIHC0=";

  buildInputs = [pkgs.openssl];
  runtimeDependencies = [pkgs.openssl];
  nativeBuildInputs = [pkgs.pkg-config];
  checkFlags = [
    # I'm not entirely sure why these fail when compiling from the flake.
    # For some reason, cargo can't find the locked version of bevy. Skipping for now.
    "--skip=should_build_native_dev"
    "--skip=should_build_native_release"
    "--skip=should_build_web_dev"
    "--skip=should_build_web_release"
    "--skip=ui"
  ];

  meta = {
    description = "A Bevy CLI tool and linter.";
    homepage = "https://github.com/TheBevyFlock/bevy_cli";
    license = lib.licenses.mit;
    maintainers = [];
  };
})
