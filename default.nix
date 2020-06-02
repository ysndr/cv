{pkgs ? import (if pin == false then <nixpkgs> else pin) {},
 pin ? ./nixpkgs.nix,
 publicdir ? "public",
 pdfout ? "curriculum-vitae-yannik-sander.pdf",
 pdfout-german ? "curriculum-vitae-yannik-sander-de.pdf",
 gifout ? "curriculum-vitae-yannik-sander.gif",
 cvsrc ? "cv.yaml",
 cvsrc-german ? "cv-german.yaml",
 cvtemplate ? "cv.tex",
 ... }:
with  import pkgs.path {
  overlays = [ ];
};
let

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      pkgs=pkgs;
  };

  script = {...} @ args: nur.repos.ysndr.lib.wrap ({
    shell = true;
  } // args);

  bin = file: script ({ inherit file; bin = true; name = file.name; });

  #;

  # --------------- Commands ----------------


  compile-pdf = script {
    name = "compile-pdf";
    paths = [latex] ++ pandoc-pkgs;
    script = ''
      pandoc ${cvsrc} -o ${publicdir}/${pdfout} --template=${cvtemplate} --pdf-engine=xelatex
    '';
  };

  compile-pdf-german = script {
    name = "compile-pdf-german";
    paths = [latex] ++ pandoc-pkgs;
    script = ''
      pandoc ${cvsrc-german} -o ${publicdir}/${pdfout-german} --template=${cvtemplate} --pdf-engine=xelatex
    '';
  };

  compile-gif = script {
    name = "compile-gif";
    paths = [imagemagick ghostscript];
    script = ''
      ${compile-pdf}
      convert -layers OptimizePlus \
              -set units PixelsPerInch \
              -delay 300 \
              -loop 0 \
              ${pdfout} \
              -density 350 \
              ${gifout}
    '';
  };

  publish = script {
    name = "publish";
    paths = [git];
    script =  ''
      set -ex
      commit=$(git log -1 --abbrev-commit --oneline | cut -f1 -d " ")

      pushd ${publicdir}
      git add .
      git commit -m "Update gist to track commit ysndr/cv@$commit"
      git rebase HEAD master
      git push
      popd
      git add public
      git commit -m "(Public) updated gist"
      echo "Done! you can now push your repo"
    '';
  };

  latex = texlive.combine {
    inherit (texlive) scheme-small
    footmisc pagecolor etoolbox xcolor tcolorbox lastpage fancyhdr  polyglossia xunicode xltxtra marginnote sectsty hyperref environ trimspaces tex-gyre alegreya
                      ;
  };

  pandoc-pkgs = [
    librsvg
    pandoc
    haskellPackages.pandoc-citeproc
  ];

  shell = mkShell {
    name = "cv-env";
    buildInputs = [] ++ map bin [
      compile-pdf
      compile-pdf-german
      compile-gif
      publish
    ] ++ pandoc-pkgs ++ [latex];
  };

in {

  inherit shell;
  ci = {
    inherit compile-pdf compile-pdf-german publish;
  };
}
