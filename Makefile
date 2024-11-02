# var
MODULE = $(notdir $(CURDIR))

# tool
CURL  = curl -L -o
CF    = clang-format -style=file -i
OPAM  = $(HOME)/bin/opam
DUNE  = $(HOME)/.opam/default/bin/dune
IDFPY = $(IDF_PATH)/tools/idf.py

# src
C += $(wildcard src/*.c*)
H += $(wildcard inc/*.h*)
J += $(wildcard lib/*.js)
M += $(wildcard src/*.ml*)
D += $(wildcard src/dune*) dune* .ocaml*

# cfg
CFLAGS += -Iinc -Itmp -ggdb -O0

# all
.PHONY: all run jc cgen
all: $(M) $(D) $(J)
run: cgen
jc: $(M) $(D) $(J)
	dune exec src/$@.exe -- $(J)
cgen: $(M) $(D) $(J)
	dune exec src/$@.exe -- $(J)

.PHONY: cpp
cpp: bin/$(MODULE) $(J)
	$^

# esp32
.PHONY: config
config: $(IDFPY)
	$< menuconfig

# clean
.PHONY: clean
clean: $(IDFPY)
	$< clean && rm -rf *build

# format
.PHONY: format
format: tmp/format_ml tmp/format_cpp tmp/format_js
tmp/format_ml: $(M) $(D) .ocamlformat
	dune build @fmt --auto-promote && touch $@
tmp/format_cpp: $(C) $(H)
	$(CF) $? && touch $@
tmp/format_js: $(J)
	$(CF) $? && touch $@

.ocamlformat:
	echo "version=$(shell ocamlformat --version)"  > $@
	echo "profile=default"                        >> $@
	echo "margin=80"                              >> $@
	echo "line-endings=lf"                        >> $@
	echo "break-cases=all"                        >> $@
	echo "wrap-comments=true"                     >> $@
	echo "break-string-literals=never"            >> $@

# rule
bin/$(MODULE): $(C) $(H) $(CP) $(HP)
	$(CXX) $(CFLAGS) -o $@ $(C) $(CP) $(L)

# doc
.PHONY: doxy
doxy: .doxygen
	rm -rf docs ; doxygen $< 1>/dev/null

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
ref: \
	ref/microrl/README.md
gz:

$(OPAM):
	bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
	$(OPAM) init -y
	$(OPAM) install -y dune utop ocaml-lsp-server ocamlformat

ref/microrl/README.md:
    git clone -o gh git@github.com:ponyatov/microrl.git ref/microrl

.PHONY: idf
idf: $(IDF_PATH)/export.sh $(IDFPY)
.PHONY: esp32
esp32: $(IDFPY)
	$< set-target esp32
