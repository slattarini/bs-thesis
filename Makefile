#-*- Makefile -*-

# be posix compatible asap
.POSIX:

# no builtin rules
.SUFFIXES:

#--------------------------------------------------------------------------

# useful programs

ZIP = zip

LATEXMK = latexmk
LATEX_CLEAN = latex-clean

PYTHON = python

# shell common settings
shell_settings = { set -e; if (set -u) >/dev/null 2>&1; then set -u; fi; }

#--------------------------------------------------------------------------

# project name
PRJ = tesi

# sources for article/book
PRJ_SRCS = \
	$(PRJ).tex \
	biblio.bib \
	chapter1.tex \
	chapter2.tex \
	chapter3.tex \
	chapter4.tex \
	frontcover.tex \
	intro.tex \
	calcgen1.tex \
	calcgen2.tex \
	calcgen3.tex


# sources for slides/notes, remove if not needed
SLIDES_SRCS = 

DIST_FILES = Makefile $(PRJ).kilepr $(PRJ_SRCS) \
			 calcgen1.py calcgen2.py calcgen3.py \
             defs.tex $(SLIDES_SRCS) allegato-notes-$(PRJ).tex \
			 slides-and-notes.tex

#--------------------------------------------------------------------------

default: pdf
pdf $(PRJ): $(PRJ)-for-display.pdf
pdfprint $(PRJ)print: $(PRJ)-for-print.pdf
slides: $(PRJ)-slides.pdf
notes: $(PRJ)-notes.pdf allegato-notes-$(PRJ).pdf
tex: $(PRJ_SRCS)
dist zip: $(PRJ).zip
.PHONY: default pdf pdfprint $(PRJ) $(PRJ)print dist tex slides notes

# hack needed
all: tex slides notes dist
	$(MAKE) pdf
	$(MAKE) pdfprint
.PHONY: all

#--------------------------------------------------------------------------

calcgen1.tex: calcgen1.py
	$(PYTHON) calcgen1.py
calcgen2.tex: calcgen2.py
	$(PYTHON) calcgen2.py
calcgen3.tex: calcgen3.py
	$(PYTHON) calcgen3.py

#--------------------------------------------------------------------------

$(PRJ)-for-display.tex: $(PRJ).tex
	cp $(PRJ).tex $(PRJ)-for-display.tex
$(PRJ)-for-print.tex: $(PRJ).tex
	cp $(PRJ).tex $(PRJ)-for-print.tex

$(PRJ)-for-display.pdf: $(PRJ_SRCS) defs.tex $(PRJ)-for-display.tex
	printf '\\relax\n' > howlinks.tex
	$(LATEXMK) -pdf $(PRJ)-for-display </dev/null
	rm -f howlinks.tex

$(PRJ)-for-print.pdf: $(PRJ_SRCS) defs.tex $(PRJ)-for-print.tex
	printf '\\def\\nolinks{1}\n' > howlinks.tex
	$(LATEXMK) -pdf $(PRJ)-for-print </dev/null
	rm -f howlinks.tex

#--------------------------------------------------------------------------

$(PRJ)-slides.tex: slides-and-notes.tex
	cp -f slides-and-notes.tex $@
$(PRJ)-notes.tex: slides-and-notes.tex
	cp -f slides-and-notes.tex $@

allegato-notes-$(PRJ).pdf: allegato-notes-$(PRJ).tex defs.tex
	$(LATEXMK) -pdf allegato-notes-$(PRJ) </dev/null

$(PRJ)-slides.pdf: $(PRJ)-slides.tex $(SLIDES_SRCS) defs.tex
	printf '\\relax\n' > hownotes.tex
	$(LATEXMK) -pdf $(PRJ)-slides </dev/null
	rm -f hownotes.tex

$(PRJ)-notes.pdf: $(PRJ)-notes.tex $(SLIDES_SRCS) defs.tex
	printf '\\def\\onlynotes{1}\n' > hownotes.tex
	$(LATEXMK) -pdf $(PRJ)-notes </dev/null
	rm -f hownotes.tex

#--------------------------------------------------------------------------

# Create a distribution tarball
$(PRJ).zip: $(DIST_FILES)
	@$(shell_settings); \
	 rm -f $@; \
	 rm -rf dist.tmpdir; \
	 mkdir -p dist.tmpdir/$(PRJ); \
	 cp $(DIST_FILES) dist.tmpdir/$(PRJ); \
	 cd dist.tmpdir; \
	 $(ZIP) -r $@ ./$(PRJ); \
	 mv -f $@ ..; \
	 cd ..; \
	 rm -rf dist.tmpdir;

#--------------------------------------------------------------------------

# clean project directory
clean: clean2
	rm -f *.tmp *.tmp[0-9]
	rm -rf *.tmpdir
	$(LATEX_CLEAN) -a
	rm -f $(PRJ).zip
	rm -f $(PRJ)-slides.tex $(PRJ)-notes.tex hownotes.tex
	rm -f $(PRJ)-for-display.tex $(PRJ)-for-print.tex howlinks.tex
	rm -f *.dep  # sometimes left by latexmk when interrupted
.PHONY: clean

# additional cleaning
clean2:
	rm -f calcgen[123].tex

#--------------------------------------------------------------------------

# vim: noet sw=4 ts=4 ft=make
