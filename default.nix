let
  # Look here for information about how to generate `nixpkgs-version.json`.
  #  → https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs
  pinnedVersion = pin: builtins.fromJSON (builtins.readFile pin);
  pinnedPkgs = pin:  import (builtins.fetchTarball {
    inherit (pinnedVersion pin) url sha256;
    name = "nixpkgs-${(pinnedVersion pin).date}";
  }) {};
  pkgs' = pinned: (
    if (!isNull pinned) then pinnedPkgs pinned 
    else import <nixpkgs> {});
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      pkgs=pkgs';
  };

in
{ pkgs ? pkgs' pinned, pinned ? null }:
with  import pkgs.path { 
  overlays = [ ];
};
let
  
  publicdir = "public";
  pdfout = "curriculum-vitae-yannik-sander.pdf";
  gifout = "curriculum-vitae-yannik-sander.gif";
  cvsrc = "cv.yaml";
  cvtemplate = "cv.tex";

  compile-pdf = pkgs.writeShellScriptBin "compile-pdf" ''
    ${pandoc}/bin/pandoc ${cvsrc} -o ${publicdir}/${pdfout} --template=${cvtemplate} --pdf-engine=xelatex
  '';

  compile-gif = pkgs.writeShellScriptBin "compile-gif" ''
    ${compile-pdf}/bin/compile-pdf
    ${imagemagick}/bin/convert -layers OptimizePlus \
                               -set units PixelsPerInch \
                               -delay 300 \
                               -loop 0 \
                               ${publicdir}/${pdfout} \
                               -density 350 \
                               ${publicdir}/${gifout}  
  '';

  publish = pkgs.writeShellScriptBin "publish-cv" ''
    set -ex

    pushd ${publicdir}
    ${git}/bin/git add .
    ${git}/bin/git commit
    ${git}/bin/git push
    popd 
    ${git}/bin/git add public 
    ${git}/bin/git commit -m "(Public) updated gist"
  '';



  latex = texlive.combine {
    inherit (texlive) scheme-small
                      collection-mathscience
                      collection-latexextra
                      ;
  };

  pandoc-pkgs = [
    librsvg
    pandoc
    haskellPackages.pandoc-citeproc
  ];

  # --------------- Commands ----------------



in {
  inherit pkgs;
  inherit (pkgs) imagemagick ghostscript;
  inherit latex pandoc-pkgs compile-pdf compile-gif publish;
} 
