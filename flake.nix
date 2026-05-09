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
        version = "0.64.1";

        x86_64-linux = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-linux-x86_64.tar.gz";
          hash = "sha256-lllXxDTjejaO10RgMI9YJFYwoYroKCApeKp3yEvo2bc=";
        };

        aarch64-linux = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-linux-arm64.tar.gz";
          hash = "sha256-xEcwJq/tN9dZr5i9z+2u92hQkw8eDhQguvX35445pAg=";
        };

        x86_64-darwin = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-macos-x86_64.tar.gz";
          hash = "sha256-4mdS0m4aP4kjR1a0+mt7DXbk4anCAtz7wd3C/bwzMb0=";
        };

        aarch64-darwin = pkgs.fetchurl {
          url = "https://github.com/facebook/pyrefly/releases/download/${version}/pyrefly-macos-arm64.tar.gz";
          hash = "sha256-7fhIWThlfAGsXYkVjVVtJ1zacweJaPSwsmYXVb6/THM=";
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
