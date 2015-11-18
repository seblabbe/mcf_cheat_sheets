FILE = cheat_sheet

tex:
	pdflatex $(FILE).tex

all: content bib
	pdflatex $(FILE).tex

content: code.sage
	sage code.sage

bib:
	pdflatex $(FILE).tex
	bibtex $(FILE)
	pdflatex $(FILE).tex
	pdflatex $(FILE).tex

.PHONY : clean
clean :
	rm -f $(FILE).aux $(FILE).log
	rm -f $(FILE).blg $(FILE).bbl
	#rm -f $(FILE).py $(FILE).sage $(FILE).sout
	rm -f $(FILE).pdf $(FILE).out
	rm -f $(FILE).toc
	rm -f $(FILE)-blx.bib
	rm -f $(FILE).run.xml
	rm -f code.sage.py
	rm -f tikz_2_pdf_all.sage.py
	rm -f density*.png
	rm -f section_*.tex
	rm -f sections.tex
	rm -f nat_ext*.pdf
	rm -f cylinders_*.pdf
	rm -f dual_patch_*.pdf
	rm -f cube.tikz
	rm -f cube.pdf
	rm -f discrepancy_histo_*.png
	rm -f lyapunov_table.tex



