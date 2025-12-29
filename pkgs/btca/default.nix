{
  pkgs,
  lib,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "btca";
  version = "0.5.9";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/btca/-/btca-${version}.tgz";
    hash = "sha256-rEzRn/F+Ef0Ez0hp2auXaisgjhIhvUy7io6129cLN6U=";
  };

  unpackPhase = ''
    tar -xzf $src package/dist/btca-linux-x64 --strip-components=2
  '';

  installPhase = ''
    mkdir -p $out/bin;
    cp btca-linux-x64 $out/bin/btca
    chmod +x $out/bin/btca
  '';

  dontConfigure = true;
  dontBuild = true;
  dontPatch = true;
  dontFixup = true;

  meta = {
    description = "CLI for asking questions about technologies using local repo context";
    homepage = "https://btca.dev";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
  };
}
