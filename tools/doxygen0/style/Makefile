DOXYGEN_OUT ?= doxygen.doxo

STYLE_DIR = ${TOP_DIR}/style
DOXYGEN = doxygen
PDFLATEX = pdflatex
DOXYGEN_HTML_DIR = html
DOXYGEN_LATEX_DIR = latex
DOXYGEN_PDF = document.pdf
DOXYGEN_PDF_TMP = ${DOXYGEN_LATEX_DIR}/refman.pdf

export TEXINPUTS = :.//:${TOP_DIR}/style:${TOP_DIR}/style/dblatex/latex/style:${TOP_DIR}/dblatex/latex/misc:${TOP_DIR}/include//
DOXYGEN_FLAGS = ${TOP_DIR}/style/doxygen.conf
PDFLATEX_FLAGS = --interaction batchmode 

.SUFFIXES : .pdf .html .tex
.PHONY : all clean html pdf doxygen

all: $(DOXYGEN_OUT)

%.doxs: %.doxi
	cat $< > $@
	$(DOXYGEN) -u $@

%.doxo: %.doxs
	$(DOXYGEN) $<
	cat $< > $@

%.pdf: %.tex
	${PDFLATEX} ${PDFLATEX_FLAGS} $^
	@${PDFLATEX} ${PDFLATEX_FLAGS} $^
	@rm -f $*.{aux,cb,idx,glo,log,out,toc}

${DOXYGEN_HTML_DIR} ${DOXYGEN_LATEX_DIR}: 
	${DOXYGEN} ${DOXYGEN_FLAGS}
	@cp ${TOP_DIR}/style/web.css ${DOXYGEN_HTML_DIR}
	@cp ${TOP_DIR}/style/print.css ${DOXYGEN_HTML_DIR}
	@cp ${TOP_DIR}/style/menu.js ${DOXYGEN_HTML_DIR}
	@mkdir ${DOXYGEN_HTML_DIR}/images
	@cp ${TOP_DIR}/style/images/* ${DOXYGEN_HTML_DIR}/images

${DOXYGEN_PDF_TMP}: PDFLATEX_FLAGS += -output-directory=${DOXYGEN_LATEX_DIR}

${DOXYGEN_PDF}: ${DOXYGEN_LATEX_DIR} ${DOXYGEN_PDF_TMP}
	cp ${DOXYGEN_PDF_TMP} $@
	@rm -fr ${DOXYGEN_LATEX_DIR}

clean:
	@rm -f *.html *.pdf *.doxo ${DOXYGEN_OUT} $(basename ${DOXYGEN_OUT}).doxs
	@rm -fr ${DOXYGEN_HTML_DIR} ${DOXYGEN_LATEX_DIR} ${DOXYGEN_PDF}
