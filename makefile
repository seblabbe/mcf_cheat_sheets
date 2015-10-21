FILE = cheat_sheet

pdf: 
	pdflatex $(FILE).tex

bib:
	pdflatex $(FILE).tex
	bibtex $(FILE)
	pdflatex $(FILE).tex
	pdflatex $(FILE).tex

content: code.sage
	sage code.sage

tikz2pdf:
	tikz2pdf cylinders_ARP_n1.tikz
	tikz2pdf cylinders_ARP_n2.tikz
	tikz2pdf cylinders_ARP_n3.tikz
	tikz2pdf nat_ext_ARP.tikz
	tikz2pdf nat_ext_Brun.tikz
	tikz2pdf nat_ext_Cassaigne.tikz
	tikz2pdf nat_ext_ARrevert.tikz

.PHONY : clean
clean :
	rm -f $(FILE).aux $(FILE).log
	rm -f $(FILE).blg $(FILE).bbl
	#rm -f $(FILE).py $(FILE).sage $(FILE).sout
	rm -f $(FILE).pdf $(FILE).out
	rm -f code.sage.py
	rm -f mesure*.png
	rm -f section*.tex
	rm -f nat_ext*.tikz
	rm -f nat_ext*.pdf



