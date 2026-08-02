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
        version = "1.2.0";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-linux-x86_64.tar.gz";
          hash = "sha256-yxOqqY7ugmdGlUEnvI05rANymE22jyPusIRRsa3ddpI=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-linux-arm64.tar.gz";
          hash = "sha256-UpMAI0Mx1+4vHro+Ac23b4xR6J0odTlcTtnVrOKnX3Q=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-macos-x86_64.tar.gz";
          hash = "sha256-8YVjhtFnaWrz/gW1wvvoB4ReM9oQJHBsvpecdKx9fN0=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-macos-arm64.tar.gz";
          hash = "sha256-MSqyHmD7Q4WkzV72i8cOJHXXtUGly1owMp23JrKxbjk=";
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
