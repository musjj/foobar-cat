{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      forEachSystem = f: nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ]
        (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forEachSystem (pkgs: {
        default = pkgs.callPackage
          ({ lib, love_0_10, stdenv, zip }:
            stdenv.mkDerivation {
              pname = "foobar";
              version = "unstable-1970-01-01";

              src = ./.;

              nativeBuildInputs = [ zip ];
              propagatedBuildInputs = [ love_0_10 ];

              buildPhase = ''
                runHook preBuild

                zip foobar.zip ./main.lua
                cat ${love_0_10}/bin/love foobar.zip >foobar
                chmod +x foobar

                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall

                mkdir -p $out/bin
                cp foobar $out/bin
                cp foobar.zip $out/bin

                runHook postInstall
              '';
            })
          { };
      });

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ zip unzip ];
          propagatedBuildInputs = with pkgs; [ love_0_10 ];
        };
      });
    };
}
