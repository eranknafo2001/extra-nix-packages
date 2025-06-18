{
  pkgs,
  lib,
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "codex-cli";
  version = "0.1.0";
  src = pkgs.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    rev = "44022db8d0c4a0cfe5b5b041ef0c1c8811ce6e12";
    sha256 = "sha256-S9xzyg6fC/uiW9xNv0HXW+GzYaJFKzjQn7ZTugc0tEM=";
  };
  sourceRoot = finalAttrs.src.name;
  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm
    pnpm.configHook
    makeWrapper
  ];

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-SyKP++eeOyoVBFscYi+Q7IxCphcEeYgpuAj70+aCdNA=";
  };

  buildPhase = ''
    cd codex-cli
    pnpm install --frozen-lockfile
    pnpm run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib

    install -Dm644 dist/cli.js $out/lib/cli/cli.js
    install -Dm644 package.json $out/lib/package.json
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/codex \
      --add-flags "$out/lib/cli/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    maintainers = [];
  };
})
