{
  description = "Portable development environments";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          common = with pkgs; [
            curl
            git
            jq
            ripgrep
            fd
            fzf
          ];

          mkEnv = { name, packages, message }:
            pkgs.mkShell {
              packages = common ++ packages;
              shellHook = ''
                printf '\n\033[1;36m%s\033[0m\n' "${message}"
                printf 'Packages are temporary and available only in this shell.\n\n'
              '';
            };
        in {
          default = mkEnv {
            name = "default";
            packages = [];
            message = "Ank development environment";
          };

          recon = mkEnv {
            name = "recon";
            packages = with pkgs; [
              amass
              dnsx
              httpx
              subfinder
              waybackurls
            ];
            message = "Recon environment ready";
          };

          web = mkEnv {
            name = "web";
            packages = with pkgs; [
              curlie
              httpie
            ];
            message = "Web environment ready";
          };

          osint = mkEnv {
            name = "osint";
            packages = with pkgs; [
              exiftool
              wget
            ];
            message = "OSINT environment ready";
          };
        });
    };
}
