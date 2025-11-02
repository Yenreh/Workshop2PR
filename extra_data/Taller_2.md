# 🧠 Taller 2 — Programación por Restricciones

**Autor:** Robinson Duque, Ph.D  
**Correo:** robinson.duque@correounivalle.edu.co  
**Fecha:** Octubre 2025  

---

## 🔎 Introducción

En este proyecto aplicarás técnicas de **Programación por Restricciones (CSP/COP)** para extender el **Job Shop Scheduling Problem (JSSP)** clásico visto en clase.  
El objetivo es modelar y resolver **dos variaciones** del problema, incorporando nuevas restricciones y objetivos que reflejen contextos **industriales, logísticos o de servicios** más realistas.

Cada equipo trabajará sobre dos versiones específicas del problema, con condiciones adicionales que requerirán modificar el modelo base, adaptar las restricciones y evaluar su impacto en la solución.

---

## 1️⃣ Job Shop

Una fábrica tiene un conjunto de **trabajos (jobs)**, cada uno compuesto por una **secuencia de operaciones (tasks)** que deben realizarse en máquinas específicas.  

Cada operación tiene:
- Una **duración conocida**
- Una **máquina asignada**
- Una **precedencia**: una operación no puede comenzar hasta que la anterior del mismo trabajo haya terminado
- Una **restricción de capacidad**: cada máquina puede ejecutar solo una operación a la vez

El **objetivo** es planificar las operaciones para **minimizar el tiempo total de finalización (makespan)**.

En clase se trabajó esta versión básica.  
A partir de ella deberás escoger **dos variaciones** que incorporen nuevas restricciones, prioridades o contextos, y presentar el informe correspondiente.

---

## 1.1 🧰 Job Shop con mantenimiento programado

**Contexto:**  
Cada máquina debe detenerse eventualmente para mantenimiento preventivo.  
Durante ese tiempo, no puede procesar operaciones.

**Nuevas restricciones:**
- Cada máquina *m* tiene intervalos [ aₘ, bₘ ] donde no está disponible.  
- Ninguna operación puede ejecutarse en la máquina *m* durante esos intervalos.

**Objetivo:**  
Minimizar el *makespan* respetando los períodos de mantenimiento.

---

## 1.2 👷 Job Shop con operarios limitados

**Contexto:**  
Algunas máquinas requieren un operario especializado, pero hay menos operarios que máquinas.

**Nuevas restricciones:**
- Solo hay *k* operarios disponibles.  
- Dos operaciones simultáneas no pueden usar el mismo operario.  
- Cada operación debe ser asignada a un operario disponible.

**Objetivo:**  
Minimizar el *makespan* y balancear la carga de trabajo de los operarios.

---

## 1.3 ⏰ Job Shop con prioridades y fechas límite

**Contexto:**  
Cada trabajo tiene una prioridad distinta *wᵢ* y una fecha límite (*due dateᵢ*).

**Nuevas restricciones:**
- Cada *job i* tiene una fecha límite *due dateᵢ*.  
- Se penalizan las operaciones que terminan después de su *due date*.

**Objetivo:**  
Minimizar la suma ponderada de tardanzas:  

\[
\sum_i w_i \times \max(0, end_i - due\_date_i)
\]

---

## 2️⃣ Informe con Modelos y Conclusiones

### 2.1 📊 Modelos

- Proponer un **formato de entrada de datos (`Datos.dzn`)** que permita configurar los parámetros de los modelos seleccionados.  
- Generar **10 instancias** para cada modelo con diferentes configuraciones.  
- Proponer un **modelo genérico en MiniZinc** para cada problema seleccionado.  
- Implementar cada modelo (por ejemplo `JobShop-mantenimiento.mzn`).  
- Incluir una **tabla con pruebas** sobre las 10 instancias y un **análisis de los resultados**.

### 2.2 📝 Informe

El informe (en PDF) debe contener, por cada ejercicio desarrollado:

1. **Modelo:** descripción de parámetros, variables, restricciones y justificación de su adecuación.  
2. **Detalles de implementación:** aspectos relevantes (restricciones redundantes, rompimiento de simetrías, etc.).  
3. **Búsqueda:** descripción de estrategias de búsqueda exploradas.  
4. **Pruebas:** descripción de las pruebas realizadas.  
5. **Análisis:** discusión sobre los resultados y estrategias.  
6. **Conclusiones:** análisis de resultados y justificación de afirmaciones.

---

## 3️⃣ Evaluación

Los criterios de calificación son:

| # | Criterio | Puntaje |
|--:|:----------|:-------:|
| 1 | Definición precisa de variables y dominios | 10 |
| 2 | Definición completa y correcta de restricciones | 15 |
| 3 | Restricciones que rompan simetrías | 10 |
| 4 | Restricciones redundantes justificadas | 10 |
| 5 | Estrategias de búsqueda analizadas y comparadas | 15 |
| 6 | Calidad y suficiencia de las pruebas | 5 |
| 7 | Coherencia entre modelos, implementaciones y análisis | 25 |
| 8 | Redacción y presentación del informe | 10 |
|  | **Total** | **100 pts** |

---

## 4️⃣ Instrucciones Finales de Entrega

Debe entregarse una carpeta comprimida **`PPR-CodEst1-CodEst2.zip`** que contenga:

1. `readme.txt` — Descripción de todos los archivos y cómo ejecutar los modelos.  
2. `informe.pdf` — Análisis de modelos e implementación.  
3. Archivos fuente `*.mzn` y `*.dzn` con los modelos y datos de prueba.

---

**Duración estimada:** 18 horas (6 horas por semana durante 3 semanas).  
**Curso:** Programación por Restricciones — Universidad del Valle.  
