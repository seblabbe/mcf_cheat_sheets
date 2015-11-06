FILE = cheat_sheet

update:
	pdflatex $(FILE).tex

bib:
	pdflatex $(FILE).tex
	bibtex $(FILE)
	pdflatex $(FILE).tex
	pdflatex $(FILE).tex

all: content tikz2pdf
	pdflatex $(FILE).tex

content: code.sage
	sage code.sage

tikz2pdf:
	sage tikz_2_pdf_all.sage

.PHONY : clean
clean :
	rm -f $(FILE).aux $(FILE).log
	rm -f $(FILE).blg $(FILE).bbl
	#rm -f $(FILE).py $(FILE).sage $(FILE).sout
	rm -f $(FILE).pdf $(FILE).out
	rm -f $(FILE).toc
	rm -f code.sage.py
	rm -f tikz_2_pdf_all.sage.py
	rm -f mesure*.png
	rm -f section*.tex
	rm -f nat_ext*.tikz
	rm -f nat_ext*.pdf
	rm -f cylinders_*.tikz
	rm -f cylinders_*.pdf
	rm -f dual_patch_*.tikz
	rm -f dual_patch_*.pdf



