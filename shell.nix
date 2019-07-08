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
    compile-pdf compile-gif publish
    latex pandoc-pkgs imagemagick ghostscript 
  ];
  shellHook = ''
  if [[ ! -d public ]]; then
    git submodule init
    git submodule update --remote
  fi
  '';
}
