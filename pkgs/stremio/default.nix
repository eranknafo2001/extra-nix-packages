{
  pkgs,
  lib,
}:
pkgs.callPackage ../stremio-linux-shell {inherit pkgs lib;}
