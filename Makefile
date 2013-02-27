#-*- Makefile -*-

# No builtin rules nor variables.
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

GNUTAR = tar
LATEXMK = latexmk
PYTHON = python

#--------------------------------------------------------------------------

PRJ = tesi

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


SLIDES_SRCS = 

DIST_FILES = Makefile $(PRJ_SRCS) \
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
dist: $(PRJ).tar.gz
.PHONY: default pdf pdfprint $(PRJ) $(PRJ)print dist tex slides notes

# hack needed
all: tex slides notes dist
	$(MAKE) pdf
	$(MAKE) pdfprint
.PHONY: all

#--------------------------------------------------------------------------

calcgen%.tex: calcgen%.py
	rm -f $@ && $(PYTHON) $< && chmod a-w $@

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

$(PRJ).tar.gz: $(DIST_FILES)
	@rm -f $@ $@-t \
	  && $(GNUTAR) --transform 's|^|./tesi/|' $(DIST_FILES) -cvzf $@-t \
	  && chmod a-w $@-t && mv -f $@-t $@

clean:
	rm -f *.tmp *.tmp[0-9]
	rm -rf *.tmpdir
	rm -f *.aux *.log *.toc *.lof *.blg *.bbl *.out *.nav *.snm *.dep
	rm -f *.fdb_latexmk
	rm -f $(PRJ).tar.gz
	rm -f $(PRJ)-slides.tex $(PRJ)-notes.tex hownotes.tex
	rm -f $(PRJ)-for-display.tex $(PRJ)-for-print.tex howlinks.tex
	rm -f calcgen[123].tex
.PHONY: clean

#--------------------------------------------------------------------------

# vim: noet sw=4 ts=4 ft=make
