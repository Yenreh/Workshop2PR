% ================================================================
% Modelo Job/Flow Shop con ventanas de mantenimiento en máquinas
% ================================================================

% ---------- Parámetros básicos del problema ----------
int: jobs;                                     % Cantidad de trabajos (jobs)
set of int: JOB = 1..jobs;

int: tasks;                                    % Cantidad de tareas/máquinas
set of int: TASK = 1..tasks;

array [JOB,TASK] of int: d;                    % Duración de cada tarea por job

% Horizonte base sin mantenimiento
int: total = sum(i in JOB, j in TASK)(d[i,j]);


% ---------- Ventanas de mantenimiento ----------
int: Nbreaks;                                  % Cantidad de intervalos de mantenimiento
set of int: BRK = 1..Nbreaks;

array [BRK] of int: brk_m;                     % Máquina asociada a cada intervalo
array [BRK] of int: brk_a;                     % Inicio del mantenimiento
array [BRK] of int: brk_b;                     % Fin del mantenimiento

% Validación básica de datos de mantenimiento
constraint forall(b in BRK)(
    brk_a[b] < brk_b[b] /\
    brk_m[b] >= min(TASK) /\ brk_m[b] <= max(TASK)
);

% Suma de tiempos de mantenimiento para acotar el horizonte
int: total_break =
    (if Nbreaks > 0 then sum(b in BRK)(brk_b[b] - brk_a[b]) else 0 endif);

% Horizonte total seguro (procesamiento + mantenimiento)
int: horizon = total + total_break;

% Número de dígitos para salida formateada
int: digs = ceil(log(10.0, max(1,horizon)));


% ---------- Variables de decisión ----------
array [JOB,TASK] of var 0..horizon: s;         % Tiempos de inicio de cada operación
var 0..horizon: end;                           % Tiempo total de finalización (makespan)


% ---------- Predicado utilitario ----------
% Verifica que dos intervalos no se solapen
predicate no_overlap(var int:s1, int:d1, var int:s2, int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;


% ---------- Restricciones ----------
% Precedencias: dentro de cada job, las tareas deben respetar el orden
constraint
    forall(i in JOB)(
        forall(j in 1..tasks-1)( s[i,j] + d[i,j] <= s[i,j+1] ) /\
        s[i,tasks] + d[i,tasks] <= end
    );

% Máquinas: no solapamiento entre tareas que comparten la misma máquina
constraint
    forall(j in TASK)(
        forall(i,k in JOB where i < k)(
            no_overlap(s[i,j], d[i,j], s[k,j], d[k,j])
        )
    );

% Restricción de mantenimiento: las tareas en la máquina afectada
% no pueden ejecutarse durante el intervalo cerrado [a,b]
constraint
    forall(b in BRK)(
        let {
            int: m = brk_m[b],
            int: a = brk_a[b],
            int: len = brk_b[b] - brk_a[b]
        } in
        forall(i in JOB)(
            no_overlap(s[i,m], d[i,m], a, len)
        )
    );


% ================================================================
% Opciones de búsqueda / solve
% ================================================================

% --- Opción A: solución directa (sin heurística de búsqueda) ---
solve minimize end;

% --- Opción B: First-Fail con indomain_min ---
% solve
%   :: int_search(array1d(s), first_fail, indomain_min)
%   minimize end;

% --- Opción C: Input Order con indomain_random ---
% solve
%   :: int_search(array1d(s), input_order, indomain_random)
%   minimize end;

% --- Opción D: Búsqueda por Jobs (secuencial por cada job) ---
%solve
%  :: seq_search([
%       int_search([s[i,j] | j in TASK], first_fail, indomain_min)
%       | i in JOB
%     ])
%  minimize end;


% ---------- Salida ----------
output
  ["end = \(end)\n"] ++
  [ show_int(digs,s[i,j]) ++ " " ++
    if j == tasks then "\n" else "" endif
  | i in JOB, j in TASK ];
