# Manual LaTeX — MIT Press technical style
# Compila con tectonic (recomendado) o pdflatex + bibtex
#
# Uso:
#   make            # compila manual.pdf
#   make clean      # borra auxiliares
#   make veryclean  # borra también el PDF

TEX := tectonic
SRC := manual.tex
PDF := manual.pdf

.PHONY: all clean veryclean

all: $(PDF)

$(PDF): $(SRC) references.bib figures/*.pdf
	$(TEX) $(SRC)

clean:
	rm -f *.aux *.log *.toc *.out *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz

veryclean: clean
	rm -f $(PDF)
