ppx\_fbt\_trace
---------------

`ppx_fbt_trace` is a ppx rewrite of the camlp4 extension `pa_fbt_trace` (see
[here][]).  Quoting the explanation found there:

This ppx extension introduces simple function boundary tracing to an OCaml
program.  Every toplevel function is rewritten to print a line whenever it is
called, allowing you to trace through all the functions being called.

This is only intended for debug use and not for production servers, since the
volume of data produced is really quite high.

Contact: [Nicolas Ojeda Bar][]

[here]: https://github.com/avsm/ocaml-fbt-trace
[Nicolas Ojeda Bar]: n.oje.bar@gmail.com

### Installation

```
opam switch 4.02.0+trunk
opam install ANSITerminal ppx_tools ocamlfind
```

And then, manually:

```
git clone https://github.com/nojb/ppx_fbt_trace
cd ppx_fbt_trace
make
make install
```

### Usage

```
ocamlfind ocamlc -package ppx_fbt_trace -linkpkg <file>.ml
```
