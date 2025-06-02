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
    rev = "0402aef126b8f94ba84a8223dbe55ca0153a3f05";
    sha256 = "sha256-6VgDMxPbJcTu/Un5mW88MNZ3Z5/F0ZP6SpahYG3+SXI=";
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
    hash = "sha256-rQusKKn+lSAMxP0QY2Pcos7TxQE2AF//xDiFAJ2gTfk=";
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
