{
  description = "hyprlogin - GPU-accelerated greetd greeter for Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprlogin-src = {
      url = "github:AuthenticSm1les/hyprlogin";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      hyprlogin-src,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      overlays.default = final: _prev: {
        hyprlogin = final.callPackage ./pkgs/hyprlogin.nix { src = hyprlogin-src; };
      };

      packages = forEachSystem (pkgs: rec {
        hyprlogin = pkgs.callPackage ./pkgs/hyprlogin.nix { src = hyprlogin-src; };
        default = hyprlogin;
      });
    };
}
