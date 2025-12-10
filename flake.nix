# based on:
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/py/pyrefly/package.nix
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
      in
      {
        packages = {
          pyrefly = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
            pname = "pyrefly";
            version = "0.45.0";

            src = pkgs.fetchFromGitHub {
              owner = "facebook";
              repo = "pyrefly";
              tag = finalAttrs.version;
              hash = "sha256-G1gE1KoAQnpuwRvcZ/W7JOzPQYi5A/x5PKHuKM50FXM=";
            };

            buildAndTestSubdir = "pyrefly";
            cargoHash = "sha256-VuASsxjSt7qAfJ5kwkC293KzypipJGEvhOOyQusge/Q=";

            nativeInstallCheckInputs = [ pkgs.versionCheckHook ];
            doInstallCheck = true;
            doCheck = false; # skip cargo tests

            # Requires unstable rust features
            env.RUSTC_BOOTSTRAP = 1;

            meta = with pkgs.lib; {
              description = "Fast type checker and IDE for Python";
              homepage = "https://github.com/facebook/pyrefly";
              license = licenses.mit;
              mainProgram = "pyrefly";
              platforms = platforms.linux ++ platforms.darwin;
              maintainers = [ ];
            };
          });
          default = self.packages.${system}.pyrefly;
        };
        apps = {
          pyrefly = flake-utils.lib.mkApp {
            drv = self.packages.${system}.pyrefly;
          };
          default = self.apps.${system}.pyrefly;
        };
      }
    );
}
