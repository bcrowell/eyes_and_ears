OUT = out
#NICE = nice
NICE = 
#LATEX = latex -output-format dvi
LATEX = latex

book: clamor_lily
	$(NICE) build.pl book >sight.lytex
	$(NICE) lilypond-book --include=melodies --output=out sight.lytex
	cd $(OUT) ; \
	cp ../sight.cls . ; \
	cp ../mytocloft.sty . ; \
	cp ../cover.ps . ; \
	cp ../copyright.tex . ; \
	cp ../brieftoc.tex . ; \
	inkscape --export-pdf="cover.pdf" ../cover.svg ; \
	perl -e 'foreach $$f(<*/*.eps>) {$$g=$$f; $$g=~s/\.eps/\.pdf/; if (! -e $$g) { $$c="epstopdf $$f"; "print $$c\n"; system $$c}}' ; \
	$(NICE) $(LATEX) sight.tex ; \
	makeindex sight.idx ; \
	$(NICE) $(LATEX) sight.tex ; \
	dvipdfmx sight.dvi ; \
	pdftk cover.pdf sight.pdf cat output temp.pdf && mv temp.pdf sight.pdf ; \
	mv sight.pdf ..

cover:
	rm -f cover.png && inkscape --without-gui --export-png=cover.png --export-background='rgb(255,255,255)' --export-dpi=300 cover.svg

catalog:
	build.pl catalog >catalog.tex
	lilypond-book --default-music-fontsize=16 --include=melodies catalog.tex
	latex catalog.latex
	dvips -q -Ppdf -u +lilypond.map catalog
	gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="catalog.pdf" -c .setpdfwrite - <catalog.ps

post:
	cp sight.pdf ~/Lightandmatter/sight/
	cp eyes_and_ears.tar.gz ~/Lightandmatter/sight/

dist:
	rm -Rf eyes_and_ears
	mkdir eyes_and_ears
	mkdir eyes_and_ears/melodies
	build.pl dist
	cp Makefile eyes_and_ears
	cp build.pl eyes_and_ears
	cp sight.cls eyes_and_ears
	cp mytocloft.sty eyes_and_ears
	cp top.tex eyes_and_ears
	cp bottom.tex eyes_and_ears
	cp list eyes_and_ears
	#cp cover_orig.png eyes_and_ears
	cp permissions eyes_and_ears
	cp Lily.pm eyes_and_ears
	cp melodies/*.ly eyes_and_ears/melodies
	cp lily.l eyes_and_ears
	cp lily.y eyes_and_ears
	cp midi.pl eyes_and_ears
	tar -zcvf eyes_and_ears.tar.gz eyes_and_ears
	rm -Rf eyes_and_ears

clamor_lily: lily.l lily.y
	# lily.l and lily.y are duplicated in clamor
	flex lily.l
	bison -d -v lily.y
	cc -c lex.yy.c lily.tab.c
	cc -o clamor_lily lex.yy.o lily.tab.o -lfl
	rm lily.tab.* lex.yy.*

prepress:
	pdftk sight.pdf cat 3-end output temp.pdf
	# The following makes Lulu not complain about missing fonts:
	gs-afpl -q  -dCompatibilityLevel=1.4 -dSubsetFonts=false -dPDFSETTINGS=/prepress -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=sight-no-cover.pdf temp.pdf -c '.setpdfwrite'
	@rm -f temp.pdf

clean:
	rm -f cover.png
	mkdir -p out # to make later logic simpler, in case it doesn't exist
	# Don't erase *.ps, because the cover photo is a .ps.
	# The following two lines are necessary in order to avoid error messages because of argument lists to rm being too long.
	cd $(OUT) ; perl -e 'foreach $$f(<lily-*.tex>) {$$c="rm -f $$f"; print "$$c\n"; system $$c}'
	cd $(OUT) ; perl -e 'foreach $$f(<lily-*.ly>) {$$c="rm -f $$f"; print "$$c\n"; system $$c}'
	cd $(OUT) ; rm -f *.log *.dvi *~ *.aux 
	cd $(OUT) ; rm -f *.idx *.ilg *.ind *.toc 
	cd $(OUT) ; rm -f sight.latex catalog.latex sight.tex sight.ps
	rm -Rf $(OUT)
	rm -Rf midi

midis:
	# The following requires csvmidi by John Walker, http://www.fourmilab.ch/webtools/midicsv/
	# This doesn't actually work. Pitches are off by an octave sometimes, e.g., in abt_aroon.mid, and
	# sometimes they are also very low for some reason.
	# Probably better to do this using lilypond's midi output, but that would seem to require
	# adding a \midi{} section to every single file, or finding a way to stick it in manually.
	mkdir -p midi
	./midi.pl
	perl -e 'foreach $$f(<midi/*.csv>) {$$g=$$f; $$g=~s/\.csv/\.mid/; $$c="csvmidi $$f $$g"; "print $$c\n"; system $$c}'
	
