#!/bin/bash

# Script para compilar el informe en LaTeX
# Ejecutar con: ./compile_report.sh

echo "Compilando informe"

# Compilar con pdflatex (primera pasada)
pdflatex -interaction=nonstopmode main.tex

# Compilar con bibtex para referencias
bibtex main

# Compilar con pdflatex (segunda pasada para referencias)
pdflatex -interaction=nonstopmode main.tex

# Compilar con pdflatex (tercera pasada para índices)
pdflatex -interaction=nonstopmode main.tex

# Limpiar archivos auxiliares
rm -f *.aux *.log *.bbl *.blg *.toc *.out *.fls *.fdb_latexmk *.synctex.gz

echo "Compilación completada. Archivo generado: main.pdf"

# Verificar si el PDF se generó correctamente
if [ -f "main.pdf" ]; then
    echo "PDF generado exitosamente"
    echo "Tamaño del archivo: $(du -h main.pdf | cut -f1)"
else
    echo "Error en la generación del PDF"
    exit 1
fi
