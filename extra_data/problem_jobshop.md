# 🧩 Job Shop Scheduling Problem (JSSP)

## 1. Descripción general

El **Job Shop Scheduling Problem (JSSP)** es un problema clásico de **Programación por Restricciones (CSP/COP)** y **Optimización Combinatoria**.  
Su propósito es determinar un **cronograma óptimo** para un conjunto de trabajos (jobs), cada uno compuesto por una **secuencia de operaciones (tasks)** que deben procesarse en **máquinas específicas** bajo restricciones de orden, capacidad y tiempo.

Cada operación se caracteriza por:
- Una **duración conocida**
- Una **máquina asignada**
- Una **dependencia secuencial** (una tarea no puede comenzar hasta que la anterior del mismo trabajo termine)
- Una **restricción de capacidad**: cada máquina solo puede procesar una tarea a la vez

El **objetivo principal** es **minimizar el makespan**, es decir, el tiempo total necesario para completar todos los trabajos.

---

## 2. Formulación general del problema

### **Conjuntos**
- `J`: conjunto de trabajos (J = {1, 2, ..., n})
- `M`: conjunto de máquinas disponibles (M = {1, 2, ..., m})

### **Parámetros**
- `duration[i,j]`: duración de la tarea del trabajo `i` en la máquina `j`
- `tasks`: número de tareas por trabajo
- `jobs`: número total de trabajos

### **Variables**
- `start[i,j]`: tiempo de inicio de la tarea `j` del trabajo `i`
- `end`: tiempo total de finalización del cronograma (makespan)

### **Restricciones**
1. **Secuencialidad interna de cada trabajo:**
   ```
   start[i,j] + duration[i,j] <= start[i,j+1]
   ```
   Las tareas de un mismo trabajo deben realizarse en orden.

2. **No solapamiento en una misma máquina:**
   ```
   start[i1,j] + duration[i1,j] <= start[i2,j]
   \/ 
   start[i2,j] + duration[i2,j] <= start[i1,j]
   ```
   Dos trabajos distintos no pueden ejecutarse al mismo tiempo en la misma máquina.

3. **Finalización dentro del horizonte de planificación:**
   ```
   start[i,tasks] + duration[i,tasks] <= end
   ```

### **Función objetivo**
Minimizar el tiempo total de finalización:
```
solve minimize end;
```

---

## 3. Implementación en MiniZinc

### 📄 **Archivo del modelo:** `jobshop.mzn`

```minizinc
int: jobs;                                    % no of jobs
set of int: JOB = 1..jobs;
int: tasks;                                   % no of tasks per job
set of int: TASK = 1..tasks;
array [JOB,TASK] of int: d;                   % task durations
int: total = sum(i in JOB, j in TASK)(d[i,j]);% total duration
int: digs = ceil(log(10.0,total));            % digits for output
array [JOB,TASK] of var 0..total: s;          % start times
var 0..total: end;                            % total end time

% nooverlap
predicate no_overlap(var int:s1, int:d1, var int:s2, int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;

constraint %% ensure the tasks occur in sequence
    forall(i in JOB) (
        forall(j in 1..tasks-1) 
            (s[i,j] + d[i,j] <= s[i,j+1]) /\
        s[i,tasks] + d[i,tasks] <= end
    );

constraint %% ensure no overlap of tasks
    forall(j in TASK) (
        forall(i,k in JOB where i < k) (
            no_overlap(s[i,j], d[i,j], s[k,j], d[k,j])
        )
    );

solve minimize end;

% Ejemplos de búsquedas alternativas
%solve :: seq_search([
%             int_search(s, smallest, indomain_min),
%             int_search([end], input_order, indomain_min)])
%      minimize end;

%solve :: seq_search([
%             int_search([end], input_order, indomain_min),
%             int_search(s, smallest, indomain_min)])
%      minimize end;

output ["end = \(end)\n"] ++
       [ show_int(digs,s[i,j]) ++ " " ++ 
         if j == tasks then "\n" else "" endif |
         i in JOB, j in TASK ];
```

---

### 📄 **Archivo de datos:** `jobshop.dzn`

```minizinc
jobs = 5;
tasks = 5;

d = [| 1, 4, 5, 3, 6
     | 3, 2, 7, 1, 2
     | 4, 4, 4, 4, 4  
     | 1, 1, 1, 6, 8
     | 7, 3, 2, 2, 1 |];
```

---

## 4. Visualización del resultado esperado

La salida mostrará el **tiempo total de finalización (`end`)** y la **matriz de tiempos de inicio (`s[i,j]`)** para cada tarea, por ejemplo:

```
end = 18
00 05 10 12 15
00 04 08 13 15
00 05 09 13 17
00 01 02 08 16
00 07 10 12 15
```

---

## 5. Extensiones sugeridas (Taller 2)

| Variación | Descripción | Nuevo objetivo |
|------------|-------------|----------------|
| **Job Shop con mantenimiento programado** | Las máquinas deben detenerse durante ciertos intervalos [a_m, b_m] | Minimizar el makespan respetando mantenimiento |
| **Job Shop con operarios limitados** | Solo hay k operarios disponibles para n máquinas | Minimizar el makespan y balancear carga |
| **Job Shop con prioridades y fechas límite** | Cada trabajo tiene un peso y fecha límite | Minimizar tardanzas ponderadas |

---

## 6. Conclusiones

El **Job Shop Problem** combina **restricciones temporales, de recursos y de precedencia**, convirtiéndose en uno de los problemas más representativos de la **Programación por Restricciones**.

Su modelamiento en **MiniZinc** permite:
- Expresar de forma declarativa las relaciones entre tareas
- Incorporar fácilmente restricciones adicionales
- Explorar estrategias de búsqueda (`seq_search`, `int_search`, etc.)
- Experimentar con extensiones realistas (mantenimiento, operarios, prioridades)
