{
  description = "Minimal Cuda Dev Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  # Add nix-community cache for unfree cuda packages
  # Requires user to be trusted user e.g. NixOs nix.settings.trusted-users
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos-cuda.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "cuda-env";

      packages = [
        pkgs.python312
        pkgs.python312Packages.torch-bin

        pkgs.cudaPackages.cuda_nvcc
        pkgs.cudaPackages.cudatoolkit
        pkgs.cudaPackages.cudnn
      ];

      shellHook = ''
        export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
        export LD_LIBRARY_PATH=/run/opengl-driver/lib:${pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
          pkgs.cudaPackages.cudatoolkit
        ]}
      '';
    };
  };
}
