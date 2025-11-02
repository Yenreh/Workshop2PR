#!/bin/bash

# Script para compilar el informe en LaTeX
# Ejecutar con: ./#!/bin/bash
# Script para compilar el informe del Taller 2

echo "======================================================"
echo "  Compilando Informe Taller 2"
echo "  Job Shop Scheduling - Extensiones"
echo "======================================================"
echo ""

cd "$(dirname "$0")"

# Verificar que existe main.tex
if [ ! -f "main.tex" ]; then
    echo "❌ Error: No se encuentra main.tex en el directorio actual"
    exit 1
fi

echo "📄 Archivo principal: main.tex"
echo ""

# Primera compilación
echo "🔄 Primera compilación (generando estructura)..."
pdflatex -interaction=nonstopmode -halt-on-error main.tex > compile.log 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Error en la primera compilación."
    echo "Ver errores en compile.log"
    tail -n 20 compile.log
    exit 1
fi

# Segunda compilación para actualizar referencias y tabla de contenidos
echo "🔄 Segunda compilación (actualizando referencias)..."
pdflatex -interaction=nonstopmode -halt-on-error main.tex >> compile.log 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Error en la segunda compilación."
    echo "Ver errores en compile.log"
    tail -n 20 compile.log
    exit 1
fi

# Tercera compilación para asegurar que todo esté correcto
echo "🔄 Tercera compilación (finalizando)..."
pdflatex -interaction=nonstopmode -halt-on-error main.tex >> compile.log 2>&1

# Verificar que se generó el PDF
if [ -f "main.pdf" ]; then
    echo ""
    echo "======================================================"
    echo "✅ Compilación exitosa"
    echo "======================================================"
    echo ""
    echo "📗 Documento generado: main.pdf"
    
    # Mostrar tamaño del PDF
    if command -v du &> /dev/null; then
        SIZE=$(du -h main.pdf | cut -f1)
        echo "📊 Tamaño: $SIZE"
    fi
    
    # Contar páginas si pdfinfo está disponible
    if command -v pdfinfo &> /dev/null; then
        PAGES=$(pdfinfo main.pdf 2>/dev/null | grep "Pages:" | awk '{print $2}')
        if [ ! -z "$PAGES" ]; then
            echo "📄 Páginas: $PAGES"
        fi
    fi
    
    echo ""
    echo "======================================================"
    
    # Opción para limpiar archivos auxiliares
    echo ""
    read -p "¿Desea limpiar archivos auxiliares? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🧹 Limpiando archivos auxiliares..."
        rm -f *.aux *.log *.toc *.out *.fls *.fdb_latexmk *.synctex.gz
        rm -f problems/*.aux
        echo "✓ Limpieza completada"
    fi
    
    echo ""
    read -p "¿Desea abrir el PDF? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "📖 Abriendo PDF..."
        if command -v xdg-open &> /dev/null; then
            xdg-open main.pdf 2>/dev/null &
        elif command -v open &> /dev/null; then
            open main.pdf 2>/dev/null &
        else
            echo "⚠️  No se pudo abrir automáticamente. Abrir manualmente: main.pdf"
        fi
    fi
else
    echo ""
    echo "======================================================"
    echo "❌ Error: No se generó el archivo PDF"
    echo "======================================================"
    echo ""
    echo "Revisar los mensajes de error anteriores"
    echo "O ejecutar manualmente: pdflatex main.tex"
    exit 1
fi

echo ""
echo "✓ Proceso completado"
echo ""

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
