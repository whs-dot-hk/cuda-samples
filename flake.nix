{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      with pkgs; {
        packages.default = gcc11Stdenv.mkDerivation {
          name = "test";
          src = ./.;
          buildInputs = [tree cmake cudaPackages_12_3.cudatoolkit linuxPackages.nvidia_x11 makeWrapper];
          installPhase = ''
            mkdir -p "$out/bin"
            cp -r ./bin/*/*/release/* "$out/bin"
            rm -rf "$out/bin/encode_output"
            rm -rf "$out/bin/output"
            for file in `ls $out/bin | grep -v '\.'`; do
            wrapProgram "$out/bin/$file" --prefix LD_LIBRARY_PATH ":" "${linuxPackages.nvidia_x11}/lib"
            done
          '';
          dontUseCmakeConfigure = true;
          CUDA_PATH = "${cudaPackages_12_3.cudatoolkit}";
          SMS = "86";
        };
      });
}
