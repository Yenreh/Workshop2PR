# Informe Taller 2 - Programación por Restricciones

Este directorio contiene el informe del Taller 2 sobre extensiones del Job Shop Scheduling Problem.

## Estructura

```
report/
├── main.tex                    # Documento principal LaTeX
├── compile_report.sh           # Script de compilación
├── README.md                   # Este archivo
├── problems/                   # Secciones individuales por problema
│   ├── jobshop_maintenance.tex         # Problema 1.1: Mantenimiento
│   ├── jobshop_op_limit.tex            # Problema 1.2a: Operarios limitados
│   └── jobshop_op_limit_skills.tex     # Problema 1.2b: Operarios con habilidades
└── images/                     # Directorio para imágenes (logo, diagramas, etc.)
```

## Contenido del Informe

El informe cubre dos variaciones del Job Shop Scheduling Problem:

### Problema 1.1: Job Shop con Mantenimiento Programado
- **Estado**: Por completar
- Restricciones adicionales de intervalos de mantenimiento en máquinas
- Objetivo: Minimizar makespan respetando períodos de inactividad

### Problema 1.2a: Job Shop con Operarios Limitados
- **Estado**: Completado con análisis de pruebas
- Restricciones de disponibilidad limitada de operarios (k < máquinas)
- Objetivo dual: Minimizar makespan y balancear carga
- Incluye:
  - Modelamiento detallado
  - 3 estrategias de búsqueda implementadas y analizadas
  - 11 instancias de prueba evaluadas
  - Análisis comparativo exhaustivo

### Problema 1.2b: Job Shop con Operarios Limitados y Habilidades
- **Estado**: Por completar
- Extensión del 1.2a con requisitos de habilidades específicas
- Operarios calificados solo para ciertas operaciones

## Compilación

### Requisitos

- LaTeX (distribución completa: TeXLive, MikTeX, etc.)
- Paquetes necesarios:
  - graphicx, amssymb, amsmath
  - babel (español)
  - hyperref, listings, xcolor
  - longtable, booktabs
  - adjustbox, placeins, bookmark

### Compilar el informe

```bash
# Opción 1: Usando el script
bash compile_report.sh

# Opción 2: Manualmente
pdflatex main.tex
pdflatex main.tex  # Segunda pasada para referencias
```

El script `compile_report.sh` ejecuta múltiples pasadas de pdflatex para resolver referencias cruzadas y genera el índice de contenidos correctamente.

### Salida

El documento compilado se genera como `main.pdf` en este directorio.

## Notas sobre el Contenido

### Secciones Completadas

- Introducción general
- Problema 1.2a completo con:
  - Descripción del problema
  - Modelamiento matemático formal
  - Variables, dominios y restricciones
  - Restricciones redundantes justificadas
  - Estrategias de ruptura de simetrías
  - 3 estrategias de búsqueda detalladas
  - Resultados experimentales de 11 instancias
  - Tablas comparativas
  - Análisis exhaustivo de resultados
  - Conclusiones específicas

### Secciones Por Completar

- Problema 1.1: Mantenimiento programado (estructura creada, contenido pendiente)
- Problema 1.2b: Operarios con habilidades (estructura creada, contenido pendiente)
- Referencias completas
- Anexos con árboles de búsqueda (si aplica)

## Datos de las Pruebas

Las pruebas realizadas se encuentran en:
- Modelos: `../jobshop_op_limit/jobshop_search_{1,2,3}.mzn`
- Datos: `../jobshop_op_limit/tests/data{00..10}.dzn`
- Resultados: `../jobshop_op_limit/output/results/gecode/`

### Configuración de las Pruebas

- **Solver**: Gecode 6.3.0
- **Límite de tiempo**: 60,000 ms (60 segundos)
- **Semilla aleatoria**: 1
- **Razón del límite**: Instancias grandes excedían 8 minutos sin convergencia

## Personalización

Antes de compilar, actualizar en `main.tex`:
- Códigos de estudiantes (líneas 48-50)
- Logo de la universidad en `images/logo.png` (o actualizar ruta)

## Estilo y Formato

El informe sigue el estilo establecido en el Workshop 1:
- Lenguaje formal pero claro
- Explicaciones matemáticas rigurosas
- Justificaciones de decisiones de modelamiento
- Análisis cuantitativos con tablas
- Código MiniZinc formateado con syntax highlighting
- Secciones estructuradas consistentemente

## Convenciones de Escritura

- Uso de tildes en español (´) correctamente escapadas en LaTeX
- Términos técnicos en inglés en cursiva cuando se introducen
- Variables matemáticas en $\text{typewriter}$ cuando son identificadores
- Ecuaciones numeradas para referencia
- Tablas y figuras con caption y label

## Autor

Informe generado para el curso de Programación por Restricciones  
Universidad del Valle  
Noviembre 2025  
Profesor: Robinson Duque
