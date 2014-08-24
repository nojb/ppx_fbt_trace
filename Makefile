#  This file is part of the ppx_fbt_trace package.
#  Copyright 2013  Nicolas Ojeda Bar

PACKAGE = ppx_fbt_trace
VERSION = 1.0.0
# Don't forget to change META file as well

OCAMLBUILD = ocamlbuild -classic-display -use-ocamlfind
BUILD = _build

all: src/fbt_trace.cma src/fbt_trace.cmxa src/fbt_trace.cmxs src/ppx_fbt_trace.byte

%.cma:
	$(OCAMLBUILD) $@

%.cmxa:
	$(OCAMLBUILD) $@

%.cmxs:
	$(OCAMLBUILD) $@

%.byte:
	$(OCAMLBUILD) $@

test:
	$(OCAMLBUILD) test/test.byte
	$(OCAMLBUILD) test/moda.byte

clean:
	$(OCAMLBUILD) -clean

# Install/uninstall

INSTALL = META \
	$(BUILD)/src/fbt_trace.cmi \
	$(BUILD)/src/fbt_trace.cma \
	$(BUILD)/src/fbt_trace.cmxa \
	$(BUILD)/src/fbt_trace.cmxs \
	./ppx_fbt_trace.byte

install: all
	ocamlfind install $(PACKAGE) $(INSTALL)

uninstall:
	ocamlfind remove $(PACKAGE)

.PHONY: %.cma %.cmxs %.cmxa clean install uninstall all %.byte test
