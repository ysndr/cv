# cv

Personal curriculum vitae [rendered](https://gist.github.com/ysndr/978662957bb9187fd52b2037466e1e34)

![](https://github.com/ysndr/cv/workflows/Compile%20CV%20and%20Upload/badge.svg)[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

## Build your own

If you are using Nix and have 5 minutes of spare time build your own copy:

```sh
$ nix build -f https://github.com/ysndr/cv/archive/master.tar.gz cv -o cv-yannik-sander.pdf
```


## Local changes

Run `nix-shell  --arg pin './.nixpkg.nix'` to drop into a preconfigured shell.
I you are also using direnv just run `direnv allow`

-----
Credits for the template this is based on go to: [Dimitrie Hoekstra](https://gitlab.com/dimitrieh/curriculumvitae-ci-boilerplate)
