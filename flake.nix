{
  description = "My custom nixpkgs overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        inherit (nixpkgs) lib;

        myPackages = {
          bevy-cli = pkgs.callPackage ./pkgs/bevy-cli {inherit pkgs lib;};
          sst-opencode-ai = pkgs.callPackage ./pkgs/opencode {inherit pkgs lib;};
          stremio-linux-shell = pkgs.callPackage ./pkgs/stremio-linux-shell {inherit pkgs lib;};
          stremio = pkgs.callPackage ./pkgs/stremio {inherit pkgs lib;};
        };
      in {
        packages = myPackages;

        # Optional: provide an overlay for use in other flakes
        overlays.default = _final: _prev: myPackages;
      }
    );
}
