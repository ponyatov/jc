# tool
CURL = curl -L -o
OPAM = $(HOME)/bin/opam

# all
.PHONY: all run
all:
run: install
	$(OPAM) install -y dune utop ocaml-lsp-server ocamlformat

# doc
.PHONY: doc
doc: \
	doc/JS/ECMA-262_1st_edition_june_1997.pdf

doc/JS/ECMA-262_1st_edition_june_1997.pdf:
	$(CURL) $@ https://ecma-international.org/wp-content/uploads/ECMA-262_1st_edition_june_1997.pdf

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
