{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "opencode";
  version = "0.5.13";

  src = pkgs.fetchzip {
    url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-linux-x64.zip";
    hash = "sha256-AbZn0RazdkmzbaOFtMvkMxHmnVsyFnw8IQhocz8BBpA=";
  };

  phases = ["installPhase" "patchPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/opencode $out/bin/opencode
    chmod +x $out/bin/opencode
  '';
}
