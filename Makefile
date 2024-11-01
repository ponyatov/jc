# tool
CURL = curl -L -o
OPAM = $(HOME)/bin/opam

# src
C += $(wildcard src/*.c*)
H += $(wildcard inc/*.h*)
J += $(wildcard lib/*.js)
M += $(wildcard src/*.ml*)
D += $(wildcard src/dune*) dune* .ocaml*

# all
.PHONY: all run
all:
run: install
	$(OPAM) install -y dune utop ocaml-lsp-server ocamlformat

# format
.PHONY: format
format: tmp/format_ml
tmp/format_ml: .ocamlformat
.ocamlformat:
	echo "version=$(shell ocamlformat --version)"  > $@
	echo "profile=default"                        >> $@
	echo "margin=80"                              >> $@
	echo "line-endings=lf"                        >> $@
	echo "break-cases=all"                        >> $@
	echo "wrap-comments=true"                     >> $@
	echo "break-string-literals=never"            >> $@

# doc
.PHONY: doc
doc: \
	doc/JS/ECMA-262_1st_edition_june_1997.pdf \
	doc/OCaml/cs3110_ocaml_programming.pdf

doc/JS/ECMA-262_1st_edition_june_1997.pdf:
	$(CURL) $@ https://ecma-international.org/wp-content/uploads/ECMA-262_1st_edition_june_1997.pdf
doc/OCaml/cs3110_ocaml_programming.pdf:
	$(CURL) $@ https://cs3110.github.io/textbook/ocaml_programming.pdf

# install
.PHONY: install update ref gz
install: $(OPAM) doc ref gz
update:
	sudo apt update
	sudo apt upgrade -uy `cat apt.txt`
ref:
gz:

$(OPAM):
	bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
	$(OPAM) init -y
	$(OPAM) install -y dune utop ocaml-lsp-server ocamlformat
