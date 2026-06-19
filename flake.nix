{
  description = "Pyrefly - A fast type checker and IDE for Python";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "1.1.1";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-linux-x86_64.tar.gz";
          hash = "sha256-f5UMJGgm6kuoi9IJzdFZMVb+2dEeIRQzTX4RJYHICoM=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-linux-arm64.tar.gz";
          hash = "sha256-MCUZKeLAdGRP6+HeSw/jBvPZ1zfwhLDKGVkFEdF052s=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-macos-x86_64.tar.gz";
          hash = "sha256-GRx+4okdKrVaBbB4yUgyJm4d2nipoDgalf3hOiono4s=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-macos-arm64.tar.gz";
          hash = "sha256-AiqYnSr0dI5NdaSP7X27DMSfMKS4N0XU5PdC0JIK2nA=";
        };
      in
      {
        packages.pyrefly = pkgs.stdenv.mkDerivation {
          pname = "pyrefly";
          inherit version;
          src =
            {
              inherit
                x86_64-linux
                aarch64-linux
                x86_64-darwin
                aarch64-darwin
                ;
            }
            .${system};
          sourceRoot = ".";
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];
          buildInputs = with pkgs; [
            stdenv.cc.cc.lib
          ];
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp pyrefly $out/bin/
            chmod +x $out/bin/pyrefly
            runHook postInstall
          '';
          meta = with pkgs.lib; {
            description = "A fast type checker and IDE for Python";
            homepage = "https://github.com/facebook/pyrefly";
            license = licenses.mit;
            mainProgram = "pyrefly";
            platforms = [
              "x86_64-linux"
              "aarch64-linux"
              "x86_64-darwin"
              "aarch64-darwin"
            ];
            maintainers = [ ];
          };
        };
        packages.default = self.packages.${system}.pyrefly;
        apps.pyrefly = flake-utils.lib.mkApp {
          drv = self.packages.${system}.pyrefly;
        };
        apps.default = self.apps.${system}.pyrefly;
      }
    );
}
