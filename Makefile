#-*- Makefile -*-

# be posix compatible asap
.POSIX:

# no builtin rules
.SUFFIXES:

#--------------------------------------------------------------------------

# useful programs

TRUE = true
FALSE = false

CP = cp
MV = mv
RM = rm
RM_F = $(RM) -f
RM_RF = $(RM) -rf
MKDIR = mkdir

ZIP = zip

PRINTF = printf
GREP = grep
SED = sed
EXPR = expr
UNIX2DOS = unix2dos

KPSEWHICH = kpsewhich

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

# non-standard packages, to be put in the distributed tarball
PRJ_PKGS = srcltx.sty # stepkg.sty
	
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
	$(CP) $(PRJ).tex $(PRJ)-for-display.tex
$(PRJ)-for-print.tex: $(PRJ).tex
	$(CP) $(PRJ).tex $(PRJ)-for-print.tex

$(PRJ)-for-display.pdf: $(PRJ_SRCS) defs.tex $(PRJ)-for-display.tex
	echo '\relax' > howlinks.tex
	$(LATEXMK) -pdf -nonstopmode $(PRJ)-for-display </dev/null
	$(RM_F) howlinks.tex

$(PRJ)-for-print.pdf: $(PRJ_SRCS) defs.tex $(PRJ)-for-print.tex
	echo '\def\nolinks{1}' > howlinks.tex
	$(LATEXMK) -pdf -nonstopmode $(PRJ)-for-print </dev/null
	$(RM_F) howlinks.tex

#--------------------------------------------------------------------------

$(PRJ)-slides.tex: slides-and-notes.tex
	$(CP) slides-and-notes.tex $@
$(PRJ)-notes.tex: slides-and-notes.tex
	$(CP) slides-and-notes.tex $@

allegato-notes-$(PRJ).pdf: allegato-notes-$(PRJ).tex defs.tex
	$(LATEXMK) -pdf -nonstopmode allegato-notes-$(PRJ) </dev/null

$(PRJ)-slides.pdf: $(PRJ)-slides.tex $(SLIDES_SRCS) defs.tex
	echo '\relax' > hownotes.tex
	$(LATEXMK) -pdf -nonstopmode $(PRJ)-slides </dev/null
	$(RM_F) hownotes.tex

$(PRJ)-notes.pdf: $(PRJ)-notes.tex $(SLIDES_SRCS) defs.tex
	echo '\def\onlynotes{1}' > hownotes.tex
	$(LATEXMK) -pdf -nonstopmode $(PRJ)-notes </dev/null
	$(RM_F) hownotes.tex

#--------------------------------------------------------------------------

# Create a distribution tarball
$(PRJ).zip: $(DIST_FILES)
	@$(shell_settings); \
	 $(RM_F) $@; \
	 $(RM_RF) dist.tmpdir; \
	 $(MKDIR) dist.tmpdir && $(MKDIR) dist.tmpdir/$(PRJ); \
	 $(CP) $(DIST_FILES) dist.tmpdir/$(PRJ); \
	 for pkg in : $(PRJ_PKGS); do \
	 	if test x"$$pkg" = x":"; then \
		  : do nothing; \
		else \
	 		pkgpath=`( $(KPSEWHICH) -must-exist "$$pkg" || $(TRUE) )`; \
			if test -n "$$pkgpath"; then \
		    	$(CP) "$$pkgpath" dist.tmpdir/$(PRJ); \
		  	else \
		    	echo "ERROR: cannot find package '$$pkg'" \
					 "in your TeX system" >&2; \
				exit 1; \
			fi; \
		fi; \
	 done; \
	 cd dist.tmpdir; \
	 $(ZIP) -r $@ ./$(PRJ); \
	 $(MV) $@ ..; \
	 cd ..; \
	 $(RM_RF) dist.tmpdir;

#--------------------------------------------------------------------------

framecount.txt: slides-and-notes.tex $(SLIDES_SRCS)
	@$(shell_settings); \
	 srcs='slides-and-notes.tex $(SLIDES_SRCS)'; \
	 $(PRINTF) '%s' 'Frames Number: '; \
     c=`$(GREP) -c '^\\\\begin{frame}' $$srcs`; \
	 c=`$(EXPR) $$c - 2`; \
	 echo $$c | tee $@.tmp; \
	 $(UNIX2DOS) $@.tmp && mv $@.tmp $@;
framecount: framecount.txt
.PHONY: framecount

#--------------------------------------------------------------------------

# clean project directory
clean: clean2
	$(RM_F) *.tmp *.tmp[0-9]
	$(RM_RF) *.tmpdir
	$(LATEX_CLEAN) -a
	$(RM_F) $(PRJ).zip
	$(RM_F) $(PRJ)-slides.tex $(PRJ)-notes.tex hownotes.tex
	$(RM_F) $(PRJ)-for-display.tex $(PRJ)-for-print.tex howlinks.tex
	$(RM_F) *.dep  # sometimes left by latexmk when interrupted
	$(RM_F) framecount.txt
.PHONY: clean

# additional cleaning
clean2:
	$(RM_F) calcgen[123].tex

#--------------------------------------------------------------------------

# vim: noet sw=4 ts=4 ft=make
