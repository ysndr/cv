# This allows overriding pkgs by passing `--arg pkgs ...` or --arg pinned './.nixpkgs-version.json'
{ pkgs ? import <nixpkgs> {}, pinned ? null }:
let
  project = import ./default.nix 
      { inherit pinned; } //
      (if (isNull pinned) then { inherit pkgs; } else {});
in with project.pkgs;
mkShell {
  name = "cv-env";
  buildInputs = with project; [
    latex pandoc-pkgs
  ];
  shellHook = ''
  '';
}
