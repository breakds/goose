# This is based on viper's article https://ayats.org/blog/nix-rustup

{
  description = "Codename Goose the AI agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, utils, devshell, rust-overlay, ... }@inputs: {
    overlays.default = final: prev: {};
  } // utils.lib.eachDefaultSystem (system: {
    # The main development environment
    devShells.default =
      let pkgs = import nixpkgs {
            inherit system;

            overlays = [
              devshell.overlays.default
              rust-overlay.overlays.default
            ];
          };

          toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

          pythonEnv = pkgs.python3.withPackages (ps: with ps; [
            numpy
          ]);

      in pkgs.devshell.mkShell {
        name = "goose";

        commands = with pkgs; [
          { name = "python"; package = pythonEnv; }
        ];

        packages = [
          toolchain
          pkgs.rust-analyzer-unwrapped
          pkgs.pkg-config
          pkgs.dbus
        ];

        env = [
          {
            name = "RUST_SRC_PATH";
            value = "${toolchain}/lib/rustlib/src/rust/library";
          }
        ];
      };
  });
}
