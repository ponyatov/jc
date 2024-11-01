# tool
CURL = curl -L -o
OPAM = $(HOME)/bin/opam

# all
.PHONY: all run
all:
run:
	$(MAKE) install

# install
.PHONY: install update ref gz
install: $(OPAM)
update:
	sudo apt update
	sudo apt upgrade -uy `cat apt.txt`
ref:
gz:

$(OPAM):
	BINDIR=$(HOME)/bin \
		bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
