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
            version = "0.52.0";

            src = pkgs.fetchFromGitHub {
              owner = "facebook";
              repo = "pyrefly";
              tag = finalAttrs.version;
              hash = "sha256-UvYM+j26qIe5yQNp0ttEvdrEoYFDvWY6xFGS0bMFXT4=";
            };

            buildAndTestSubdir = "pyrefly";
            cargoHash = "sha256-gzaRZys2F9fyv0Q0gAAg3UdxF9rMMI6+lzZPhnrVC00=";

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
