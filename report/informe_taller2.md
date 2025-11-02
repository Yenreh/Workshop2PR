# Informe Taller 2 - Programación por Restricciones
## Extensiones del Job Shop Scheduling Problem

**Autores:** [Código Estudiante 1] - [Código Estudiante 2]  
**Curso:** Programación por Restricciones  
**Profesor:** Robinson Duque, Ph.D.  
**Universidad del Valle**  
**Fecha:** Noviembre 2025

---

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Problema 1.1: Job Shop con Mantenimiento Programado](#problema-11-job-shop-con-mantenimiento-programado)
3. [Problema 1.2a: Job Shop con Operarios Limitados](#problema-12a-job-shop-con-operarios-limitados)
4. [Problema 1.2b: Job Shop con Operarios Limitados y Habilidades](#problema-12b-job-shop-con-operarios-limitados-y-habilidades)
5. [Conclusiones Generales](#conclusiones-generales)
6. [Referencias](#referencias)

---

## Introducción

Este informe presenta el desarrollo e implementación de extensiones del problema clásico de Job Shop Scheduling (JSSP) utilizando MiniZinc. El JSSP es un problema de optimización combinatoria donde se deben planificar operaciones de múltiples trabajos en diferentes máquinas, respetando restricciones de precedencia y capacidad, con el objetivo de minimizar el tiempo total de finalización (makespan).

En este taller se abordan dos variaciones del problema que incorporan restricciones adicionales que reflejan contextos industriales y logísticos más realistas:

1. **Job Shop con Mantenimiento Programado:** Cada máquina debe detenerse periódicamente para mantenimiento preventivo, durante el cual no puede procesar operaciones.

2. **Job Shop con Operarios Limitados:** Algunas máquinas requieren operarios especializados, pero hay menos operarios disponibles que máquinas, lo que añade restricciones adicionales de asignación y concurrencia.

Para cada problema se presentan las variables de decisión, dominios, restricciones, detalles de implementación, restricciones redundantes, estrategias de ruptura de simetrías, estrategias de búsqueda, pruebas exhaustivas y análisis de resultados.

---

## Problema 1.1: Job Shop con Mantenimiento Programado

### Descripción del Problema

[Por completar]

### Modelamiento como CSP

[Por completar]

### Detalles de Implementación

[Por completar]

### Estrategias de Búsqueda

[Por completar]

### Pruebas Realizadas

[Por completar]

### Análisis de Resultados

[Por completar]

### Conclusiones

[Por completar]

---

## Problema 1.2a: Job Shop con Operarios Limitados

### Descripción del Problema

En esta variación del Job Shop Scheduling Problem, se introduce la restricción de que hay un número limitado de operarios especializados disponibles. Aunque cada operación requiere ejecutarse en una máquina específica, también requiere la presencia de un operario para supervisarla u operarla. Como hay menos operarios que máquinas, no todas las máquinas pueden funcionar simultáneamente.

**Contexto industrial:** En entornos de producción modernos, aunque las máquinas puedan ser numerosas y especializadas, el personal calificado para operarlas es un recurso limitado y costoso.

**Elementos del problema:**
- Trabajos con secuencias de tareas
- Cada operación tiene duración fija y máquina asignada
- Restricciones de precedencia
- **Nuevo:** Solo hay k operarios disponibles
- **Nuevo:** Cada operación requiere un operario
- **Nuevo:** Un operario no puede estar en dos lugares simultáneamente
- **Objetivos duales:** Minimizar makespan y balancear carga

### Modelamiento como CSP

#### Parámetros

- **jobs** (int): Número de trabajos
- **tasks** (int): Número de operaciones por trabajo
- **k** (int): Número de operarios disponibles
- **d** (array[JOB, TASK] of int): Matriz de duraciones

#### Variables de Decisión

1. **s** (array[JOB, TASK] of var 0..total): Tiempos de inicio
2. **o** (array[JOB, TASK] of var OP): Asignación de operarios
3. **end** (var 0..total): Makespan
4. **used** (array[OP] of var bool): Operarios utilizados
5. **carga** (array[OP] of var 0..total): Carga por operario

#### Restricciones Principales

1. **Precedencia:** `s[i,j] + d[i,j] <= s[i,j+1]`
2. **Capacidad de máquinas:** `disjunctive` por tarea
3. **Makespan:** `s[i,tasks] + d[i,tasks] <= end`
4. **No solapamiento de operarios:** Si `o[i1,j1] = o[i2,j2]` entonces intervalos disjuntos
5. **Carga:** Suma de duraciones por operario

#### Ruptura de Simetrías

- Uso consecutivo de operarios
- Anclaje: `o[1,1] = 1`
- Ordenamiento de cargas decrecientes

#### Restricción Redundante

- **cumulative:** A lo sumo k tareas simultáneas

### Estrategias de Búsqueda

#### Estrategia 1: Búsqueda Libre
```minizinc
solve minimize W * end + (maxload - minload);
```
Sin anotaciones explícitas, usa heurísticas por defecto del solver.

#### Estrategia 2: dom_w_deg para Tiempos
```minizinc
solve
:: seq_search([
     int_search([s[i,j] | i in JOB, j in TASK], 
                dom_w_deg, indomain_min),
     int_search([o[i,j] | i in JOB, j in TASK], 
                first_fail, indomain_min)
   ])
minimize W * end + (maxload - minload);
```

Decide tiempos primero con heurística dinámica, luego operarios.

#### Estrategia 3: Operarios Primero
```minizinc
solve
:: seq_search([
     int_search([o[i,j] | i in JOB, j in TASK], 
                first_fail, indomain_min),
     int_search([s[i,j] | i in JOB, j in TASK], 
                first_fail, indomain_min)
   ])
minimize W * end + (maxload - minload);
```

Decide operarios antes que tiempos.

### Pruebas Realizadas

#### Configuración

- **Solver:** Gecode 6.3.0
- **Límite de tiempo:** 60,000 ms (60 segundos)
- **Semilla:** 1
- **Instancias:** 11 archivos (data00.dzn a data10.dzn)

**Justificación del límite:** Instancias grandes excedían 8 minutos sin convergencia.

#### Características de las Instancias

| Instancia | Jobs | Tasks | Operarios (k) | Operaciones | Carga Total |
|-----------|------|-------|---------------|-------------|-------------|
| data00    | 4    | 4     | 3             | 16          | 86          |
| data01    | 5    | 5     | 2             | 25          | 108         |
| data02    | 5    | 5     | 3             | 25          | 112         |
| data03    | 5    | 5     | 4             | 25          | 120         |
| data04    | 6    | 4     | 2             | 24          | 118         |
| data05    | 6    | 4     | 3             | 24          | 120         |
| data06    | 6    | 6     | 4             | 36          | 138         |
| data07    | 7    | 5     | 2             | 35          | 162         |
| data08    | 7    | 5     | 3             | 35          | 155         |
| data09    | 8    | 5     | 3             | 40          | 175         |
| data10    | 8    | 6     | 4             | 48          | 187         |

### Resultados Experimentales

#### Comparación de Makespan

| Instancia | Estrategia 1 | **Estrategia 2** | Estrategia 3 | Mejora |
|-----------|--------------|------------------|--------------|--------|
| data00    | 86           | **39**           | 86           | 54.7%  |
| data01    | 108          | **57**           | 108          | 47.2%  |
| data02    | 112          | **54**           | 112          | 51.8%  |
| data03    | 120          | **45**           | 120          | 62.5%  |
| data04    | 118          | **62**           | 118          | 47.5%  |
| data05    | 120          | **43**           | 120          | 64.2%  |
| data06    | 138          | **65**           | 138          | 52.9%  |
| data07    | 162          | **86**           | 162          | 46.9%  |
| data08    | 155          | **66**           | 155          | 57.4%  |
| data09    | 175          | **71**           | 175          | 59.4%  |
| data10    | 187          | **84**           | 187          | 55.1%  |
| **Media** | ---          | ---              | ---          | **54.3%** |

#### Comparación de Balanceo (Desbalance)

| Instancia | Estrategia 1 | **Estrategia 2** | Estrategia 3 |
|-----------|--------------|------------------|--------------|
| data00    | 86           | **1**            | 86           |
| data01    | 108          | **4**            | 108          |
| data02    | 112          | **1**            | 112          |
| data03    | 120          | **0**            | 120          |
| data04    | 118          | **0**            | 118          |
| data05    | 120          | **0**            | 120          |
| data06    | 138          | **1**            | 138          |
| data07    | 162          | **6**            | 162          |
| data08    | 155          | **1**            | 155          |
| data09    | 175          | **1**            | 175          |
| data10    | 187          | **1**            | 187          |

**Observaciones:**
- Estrategias 1 y 3: Un solo operario hace todo (desbalance = makespan)
- Estrategia 2: Balanceo casi perfecto (desbalance ≤ 6)
- 3 instancias con balanceo perfecto (desbalance = 0)

#### Eficiencia Computacional

| Métrica            | Estrategia 1 | **Estrategia 2** | Estrategia 3 |
|--------------------|--------------|------------------|--------------|
| Nodos promedio     | 8,359,786    | **5,720,751**    | 11,914,174   |
| Propagaciones (M)  | 816.2        | **771.9**        | 992.3        |
| Mejor caso (nodos) | 7,500,955    | **4,061**        | 8,088,673    |

### Análisis de Resultados

#### Hallazgos Principales

1. **Estrategia 2 es dramáticamente superior:**
   - Reduce makespan en promedio 54.3%
   - Logra balanceo casi perfecto (desbalance ≤ 6)
   - Menor número promedio de nodos explorados

2. **Estrategias 1 y 3 fallan sistemáticamente:**
   - Convergen a soluciones triviales (un operario hace todo)
   - Alto número de nodos sin mejora de calidad
   - Estrategia 3 es incluso peor que la 1 (42% más nodos)

3. **La heurística dom_w_deg es efectiva:**
   - Se adapta dinámicamente a conflictos
   - Prioriza variables más restringidas
   - Funciona especialmente bien combinada con decidir tiempos antes que operarios

4. **El orden de decisiones es crítico:**
   - Decidir tiempos primero permite aprovechar información de duraciones y precedencias
   - Decidir operarios primero (Estrategia 3) lleva a asignaciones prematuras y pobres

5. **Variabilidad estructural:**
   - data03 y data05: Muy eficientes (miles de nodos)
   - data00, data02, data06: Menos eficientes (millones de nodos)
   - La estructura específica de cada instancia afecta significativamente la dificultad

#### Ejemplo Concreto: data03

**Características:**
- 5 jobs, 5 tasks, 4 operarios
- Carga total: 120

**Resultados:**

| Estrategia | Makespan | Desbalance | Carga               | Nodos       |
|------------|----------|------------|---------------------|-------------|
| 1          | 120      | 120        | [120, 0, 0, 0]      | 8,977,618   |
| **2**      | **45**   | **0**      | **[30, 30, 30, 30]**| **4,061**   |
| 3          | 120      | 120        | [120, 0, 0, 0]      | 12,804,492  |

Estrategia 2 logra:
- Reducción de makespan: 62.5%
- Balanceo perfecto: cada operario trabaja exactamente 30 unidades
- Eficiencia computacional: 2,200x menos nodos que Estrategia 1

### Conclusiones del Problema 1.2a

1. **La estrategia de búsqueda es crítica:** La diferencia no es marginal sino cualitativa. La misma instancia genera soluciones triviales o óptimas dependiendo de la estrategia.

2. **dom_w_deg supera heurísticas por defecto:** La adaptación dinámica a la estructura del problema resulta en mejoras dramáticas de eficiencia y calidad.

3. **El orden de decisiones importa:** Tiempos primero, operarios después. El orden inverso lleva a decisiones prematuras sin suficiente información.

4. **Restricciones redundantes son necesarias pero no suficientes:** `cumulative` ayuda pero requiere combinarse con buenas estrategias de búsqueda.

5. **Objetivos múltiples bien balanceados:** La función objetivo con peso alto para makespan funciona cuando la estrategia explora diversidad de soluciones.

6. **Límites prácticos de tiempo:** 60 segundos fue necesario pero probablemente interrumpió búsquedas prometedoras en Estrategia 2.

---

## Problema 1.2b: Job Shop con Operarios Limitados y Habilidades

### Descripción del Problema

[Por completar]

### Modelamiento como CSP

[Por completar]

### Detalles de Implementación

[Por completar]

### Estrategias de Búsqueda

[Por completar]

### Pruebas Realizadas

[Por completar]

### Análisis de Resultados

[Por completar]

### Conclusiones

[Por completar]

---

## Conclusiones Generales

El desarrollo de este taller ha permitido aplicar técnicas avanzadas de modelamiento de problemas de optimización combinatoria mediante programación por restricciones. Los aspectos más relevantes incluyen:

1. **Modelamiento de restricciones complejas:** La incorporación de recursos limitados y restricciones temporales requiere análisis cuidadoso de interacciones.

2. **Uso estratégico de restricciones redundantes:** `cumulative` y otras restricciones globales reducen significativamente el espacio de búsqueda.

3. **Ruptura de simetrías esencial:** Ordenamiento de operarios y cargas es crucial para evitar explorar soluciones equivalentes.

4. **Impacto crítico de estrategias de búsqueda:** La diferencia entre estrategias puede ser la diferencia entre soluciones inútiles y óptimas.

5. **Trade-offs en optimización multi-objetivo:** Balancear múltiples objetivos requiere pesos cuidadosos y estrategias que exploren diversidad.

6. **Escalabilidad y límites computacionales:** Instancias grandes motivan el uso de límites de tiempo y estrategias especializadas.

---

## Referencias

1. MiniZinc Documentation: https://www.minizinc.org/doc-latest/en/
2. MiniZinc Handbook, Peter J. Stuckey et al.
3. Taller 2 -- Programación por Restricciones, Universidad del Valle, 2025
4. Brucker, P. (2007). Scheduling Algorithms. Springer.
5. Baptiste, P., Le Pape, C., & Nuijten, W. (2012). Constraint-Based Scheduling. Springer.

---

## Anexos

### A. Formato de Datos (.dzn)

Ejemplo de instancia (data03.dzn):
```
jobs = 5;
tasks = 5;
k = 4;

d = [| 1, 4, 2, 7, 3
 | 5, 4, 7, 1, 3
 | 3, 8, 7, 6, 6
 | 8, 6, 3, 3, 4
 | 8, 5, 6, 4, 6 |];
```

### B. Comandos de Ejecución

```bash
# Ejecutar modelo con solver específico
minizinc --solver gecode jobshop_search_2.mzn data03.dzn

# Ejecutar con límite de tiempo
minizinc --solver gecode --time-limit 60000 jobshop_search_2.mzn data03.dzn

# Ejecutar suite de pruebas
bash run_jobshop_tests.sh -s gecode -m 2
```

---

**Documento generado para el curso de Programación por Restricciones**  
**Universidad del Valle - Noviembre 2025**
