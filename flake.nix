{
  description = "Ondsel package from AppImage";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    ondsel-appimage-x86_64-linux.url = "https://github.com/Ondsel-Development/FreeCAD/releases/download/2024.1.0/Ondsel_ES_2024.1.0.35694-Linux-x86_64.AppImage";
    ondsel-appimage-x86_64-linux.flake = false;
    ondsel-appimage-aarch64-linux.url = "https://github.com/Ondsel-Development/FreeCAD/releases/download/2024.1.0/Ondsel_ES_2024.1.0.35694-Linux-aarch64.AppImage";
    ondsel-appimage-aarch64-linux.flake = false;
    ondsel-feedstock.url = "github:Ondsel-Development/freecad-feedstock";
    ondsel-feedstock.flake = false;
  };

  outputs = { nixpkgs, ... }@inputs: {
    packages = builtins.listToAttrs (map
      (system: {
        name = system;
        value = with import nixpkgs { inherit system; }; rec {

          # ondsel-app = appimageTools.wrapType2 {
          #   name = "ondsel";
          #   src = inputs."ondsel-appimage-${system}";
          # };

          default = ondsel;

          ondsel = pkgs.libsForQt5.callPackage ./ondsel.nix {
            boost = python3Packages.boost;
            inherit (python3Packages)
              gitpython
              matplotlib
              pivy
              ply
              pycollada
              pyside2
              pyside2-tools
              python
              pyyaml
              scipy
              shiboken2;
          };

        };
      }) [ "x86_64-linux" "aarch64-linux" ]);
  };
}
