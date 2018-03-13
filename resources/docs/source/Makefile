GUIDE_SOURCES=adding_test.tex fuego-guide.tex intro.tex overlays.tex  running_tests.tex board_config.tex install.tex listings.tex reports.tex testplans.tex
SCHEME_SOURCES=overlays_example.dot  overlays_toplevel.dot testplans_example.dot testplans_toplevel.dot

fuego-docs.pdf: $(GUIDE_SOURCES)
	pdflatex fuego-guide.tex	
	mv fuego-guide.pdf ../fuego-docs.pdf

schemes: $(SCHEME_SOURCES)
	dot -Tpng overlays_toplevel.dot > overlays_toplevel.png
	dot -Tpng overlays_example.dot > overlays_example.png
	dot -Tpng testplans_toplevel.dot > testplans_toplevel.png
	dot -Tpng testplans_example.dot > testplans_example.png


.PHONY: clean
clean:
	rm  *.out *.toc *.aux *.log *.pdf 2>/dev/null >/dev/null || true

