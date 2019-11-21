{pkgs ? import (if pin == false then <nixpkgs> else pin) {},
 pin ? ./nixpkgs.nix, 
 publicdir ? "public",
 pdfout ? "curriculum-vitae-yannik-sander.pdf",
 gifout ? "curriculum-vitae-yannik-sander.gif",
 cvsrc ? "cv.yaml",
 cvtemplate ? "cv.tex",
 ... }:
with  import pkgs.path { 
  overlays = [ ];
};
let

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      pkgs=pkgs;
  };

  script = {...} @ args: nur-local.lib.wrap ({
    shell = true;
  } // args);
  
  bin = file: script ({ inherit file; bin = true; name = file.name; });
  
  #= nur.repos.ysndr.lib.wrap;
 
  # --------------- Commands ----------------
 

  compile-pdf = script {
    name = "compile-pdf";
    paths = [latex] ++ pandoc-pkgs;
    script = ''
      echo I got executed
      # pandoc ${cvsrc} -o ${publicdir}/${pdfout} --template=${cvtemplate} --pdf-engine=xelatex
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

      git submodule init -- ${publicdir}

      if [ $# -lt 2 ]; then
        echo "Info: using default git config"
      elif
        src-url=$1
        result-url=$2
        git config submodule.${publicdir}.url $result-url
      fi
    

      git submodule update --init --remote --rebase

      ${compile-pdf}

      pushd ${publicdir}
      git add .
      git commit
      git push
      popd
      git add public 
      git commit -m "(Public) updated gist"
      git push $src-url
    '';
  };

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

  shell = mkShell {
    name = "cv-env";
    buildInputs = [] ++ map bin [
      (compile-pdf pdfout)
      (compile-gif pdfout gifout)
      publish
    ];
  };

in {
  
  inherit shell; 
  ci = {
    inherit compile-pdf publish;
  };
} 
