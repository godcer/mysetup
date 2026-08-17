{
  description = "Ank's portable development environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          common = with pkgs; [
            curl
            git
            jq
            ripgrep
            fd
            fzf
          ];

          recon = with pkgs; [
            amass
            dnsx
            httpx
            subfinder
            waybackurls
          ];

          web = with pkgs; [
            curlie
            httpie
            jq
            ripgrep
          ];

          osint = with pkgs; [
            exiftool
            jq
            ripgrep
            wget
          ];
        in {
          default = pkgs.mkShell {
            packages = common;
          };

          recon = pkgs.mkShell {
            packages = common ++ recon;
            shellHook = ''
              echo "Recon environment ready."
              echo "Temporary: packages exist only in this shell."
            '';
          };

          web = pkgs.mkShell {
            packages = common ++ web;
            shellHook = ''
              echo "Web environment ready."
              echo "Temporary: packages exist only in this shell."
            '';
          };

          osint = pkgs.mkShell {
            packages = common ++ osint;
            shellHook = ''
              echo "OSINT environment ready."
              echo "Temporary: packages exist only in this shell."
            '';
          };
        });
    };
}
