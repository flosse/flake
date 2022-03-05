{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    nix-dart.url = "github:tadfisher/nix-dart";
  };

  outputs = { self, nixpkgs, utils, nix-dart, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      sass = with pkgs; nix-dart.builders.${system}.buildDartPackage rec {
        pname = "dart-sass";
        version = "1.49.9";

        src = fetchFromGitHub {
          owner = "sass";
          repo = pname;
          rev = version;
          hash = "sha256-FBcXlurgVDqcVPWPpXR2SGBc4SestGv9yovkFmiW5Gs=";
        };

        specFile = "${src}/pubspec.yaml";
        lockFile = ./pub2nix.lock;

        meta = with lib; {
          description = "The reference implementation of Sass, written in Dart";
          homepage = "https://sass-lang.com/dart-sass";
          maintainers = [ maintainers.tadfisher ];
          license = licenses.mit;
        };
      };
    in
    {
      packages.${system}.dart-sass = with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation {
          name = "dart-sass";
          nativeBuildInputs = [ sass ];
          src = self;
          installPhase = "mkdir -p $out/bin; install -t $out/bin ${sass}/bin/sass";
        };
    };
}

