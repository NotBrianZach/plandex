{
  description = "A flake for building the Plandex package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        fetchSrc = version: hash: pkgs.fetchFromGitHub {
          owner = "plandex-ai";
          repo = "plandex";
          rev = "refs/tags/cli/v${version}";
          hash = hash;
        };
        fetchSurvey = version: hash: pkgs.fetchFromGitHub {
          owner = "plandex-ai";
          repo = "survey";
          rev = "refs/tags/v${version}";
          hash = hash;
        };
      in
      {
        packages.plandex = pkgs.buildGoModule rec {
          pname = "plandex";
          version = "0.8.3";
          hash = "sha256-+eLvdiP24ZX7DvNCzSHehShSjGK9XQ5b3wHzQozR91w=";
          src = pkgs.runCommand "sources" { } ''
            mkdir $out
            cp -a ${fetchSrc version hash} $out/plandex
            cp -a ${fetchSurvey surveyVersion surveyHash} $out/survey
          '';
          sourceRoot = "sources/plandex/app/cli";
          vendorHash = "sha256-kCM0SLE8jqrB21HBNi5aK9h90XqCKAmHC2iEDbOt4Uw=";
          surveyVersion = "2.3.7";
          surveyHash = "sha256-SWOmUxKdS3wZxEDZCuyTmB1DA29GoaYj5M1e0ivllCg=";
          passthru.updateScript = pkgs.nix-update-script { };
          meta = with pkgs.lib; {
            description = "An open source, terminal-based AI coding engine for complex tasks.";
            changelog = "https://github.com/plandex-ai/plandex/releases/tag/cli/v${version}";
            homepage = "https://plandex.ai/";
            platforms = platforms.linux ++ platforms.darwin;
            license = licenses.agpl3Only;
            maintainers = with maintainers; [ mattchrist ];
            mainProgram = "plandex";
          };
        };

        defaultPackage = self.packages.${system}.plandex;
      }
    );
}
