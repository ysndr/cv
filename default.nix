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
  inherit latex pandoc-pkgs;
} 
