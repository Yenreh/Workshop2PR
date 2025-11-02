#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# PARSE ARGUMENTS
# ==========================================================

usage() {
  cat <<EOF
Uso: $0 [OPCIONES]

Opciones:
  -s, --solver SOLVER       Solver a usar (chuffed, gecode, highs)
                           Si no se especifica, usa todos los disponibles
  -m, --model NUM          Número de modelo (1, 2, 3, ...)
                           Si no se especifica, usa todos los modelos
  -h, --help               Muestra esta ayuda

Ejemplos:
  $0 -s highs -m 1         # Solo highs con jobshop_search_1.mzn
  $0 -s or-tools           # or-tools con todos los modelos
  $0 -m 1                  # Todos los solvers con jobshop_search_1.mzn
  $0                       # Todos los solvers con todos los modelos
EOF
  exit 0
}

# Parámetros por defecto (vacío = usar todos)
SELECTED_SOLVER=""
SELECTED_MODEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--solver)
      SELECTED_SOLVER="$2"
      shift 2
      ;;
    -m|--model)
      SELECTED_MODEL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Opción desconocida: $1"
      usage
      ;;
  esac
done

# ==========================================================
# CONFIG
# ==========================================================

# 1) Detecta MiniZinc (usa tu ruta si lo prefieres)
if command -v minizinc >/dev/null 2>&1; then
  MINIZINC_BIN="$(command -v minizinc)"
else
  MINIZINC_BIN="/home/yenreh/Documents/MiniZincIDE/bin/minizinc"
fi

# 2) Solvers disponibles
ALL_SOLVERS=("chuffed" "gecode" "highs")

# 3) Límite de tiempo por corrida (ms)
TIME_LIMIT_MS=60000

# 4) Semilla para reproducibilidad
RANDOM_SEED=1

# 5) Estructura de proyecto
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${ROOT_DIR}/output"
TESTS_DIR="${ROOT_DIR}/tests"

# Modelos: busca todos los jobshop_search_*.mzn en el directorio raíz
readarray -t ALL_MODELS < <(ls -1 "${ROOT_DIR}"/jobshop_search_*.mzn 2>/dev/null | sort)

# 6) Opcional: cota superior para end (vacío para no usar)
UB_END=""

# 7) Modo de soluciones:
#    - Deja EMPTY para obtener sólo la mejor (más limpio + rápido de parsear)
#    - Usa "-a" si quieres todas las soluciones impresas
ALL_SOLUTIONS_FLAG=""

# ==========================================================
# UTILS
# ==========================================================

ts() { date +"%Y-%m-%d %H:%M:%S"; }

ensure_dirs() {
  mkdir -p "${OUTPUT_DIR}"
  mkdir -p "${TESTS_DIR}"
  mkdir -p "${OUTPUT_DIR}/results"
}

# Parsear del log la ÚLTIMA solución impresa (la mejor conocida)
# Extrae:
#   end = N
#   desbalance = M
#   carga_por_operario = [...]
#   y de estadísticas (-s) intenta time y nodes si están
parse_and_append_csv() {
  local log_file="$1"
  local csv_file="$2"
  local solver="$3"
  local model_tag="$4"
  local data_tag="$5"

  # Últimos valores de end, desbalance y carga
  local end_val desb_val carga_val
  end_val="$(grep -E '^[[:space:]]*end = ' "$log_file" | tail -n1 | sed -E 's/.*end = ([0-9]+).*/\1/')"
  desb_val="$(grep -E '^[[:space:]]*desbalance = ' "$log_file" | tail -n1 | sed -E 's/.*desbalance = ([0-9]+).*/\1/')"
  carga_val="$(grep -E '^[[:space:]]*carga_por_operario = ' "$log_file" | tail -n1 | sed -E 's/.*carga_por_operario = (.*)/\1/')"

  # Stats típicas (-s). Distintos solvers imprimen distinto;
  # tomamos lo que haya disponible sin romper si falta.
  local time_ms nodes fails propagations
  time_ms="$(grep -iE 'time:|^%%%mzn-stat: time=' "$log_file" | tail -n1 | sed -E 's/[^0-9]*([0-9]+)[^0-9]*/\1/' || true)"
  nodes="$(grep -iE 'nodes:|^%%%mzn-stat: nodes=' "$log_file" | tail -n1 | sed -E 's/[^0-9]*([0-9]+)[^0-9]*/\1/' || true)"
  fails="$(grep -iE 'fail|fails|^%%%mzn-stat: failures=' "$log_file" | tail -n1 | sed -E 's/[^0-9]*([0-9]+)[^0-9]*/\1/' || true)"
  propagations="$(grep -iE 'propagations|^%%%mzn-stat: propagations=' "$log_file" | tail -n1 | sed -E 's/[^0-9]*([0-9]+)[^0-9]*/\1/' || true)"

  # Limpia valores vacíos
  [[ -z "${end_val:-}" ]] && end_val="NA"
  [[ -z "${desb_val:-}" ]] && desb_val="NA"
  [[ -z "${carga_val:-}" ]] && carga_val="NA"
  [[ -z "${time_ms:-}" ]] && time_ms="NA"
  [[ -z "${nodes:-}" ]] && nodes="NA"
  [[ -z "${fails:-}" ]] && fails="NA"
  [[ -z "${propagations:-}" ]] && propagations="NA"

  echo "${solver},${model_tag},${data_tag},${end_val},${desb_val},\"${carga_val}\",${time_ms},${nodes},${fails},${propagations}" >> "${csv_file}"
}

# Ejecuta una corrida y guarda logs y CSV
run_one() {
  local solver="$1"
  local model="$2"
  local dzn="$3"

  local model_base
  model_base="$(basename "${model}" .mzn)"            # p.ej., jobshop_search_1
  local data_base
  data_base="$(basename "${dzn}" .dzn)"               # p.ej., data03

  local result_dir="${OUTPUT_DIR}/results/${solver}/${model_base}"
  mkdir -p "${result_dir}"

  local log_file="${result_dir}/${data_base}.log"
  local csv_file="${result_dir}/summary_${model_base}.csv"

  # CSV header si no existe
  if [[ ! -f "${csv_file}" ]]; then
    echo "solver,model,data,end,desbalance,carga_por_operario,time_ms,nodes,failures,propagations" > "${csv_file}"
  fi

  echo "[$(ts)] -> ${solver} | ${model_base} | ${data_base}"
  # Construye línea de bandera para ub_end si está definida
  local ub_flag=()
  if [[ -n "${UB_END}" ]]; then
    ub_flag=( --cmdline-data "ub_end=${UB_END}" )
  fi

  # Ejecutar MiniZinc
  set +e
  "${MINIZINC_BIN}" \
      --solver "${solver}" \
      -s \
      ${ALL_SOLUTIONS_FLAG} \
      --random-seed "${RANDOM_SEED}" \
      --time-limit "${TIME_LIMIT_MS}" \
      "${model}" "${dzn}" \
      "${ub_flag[@]}" \
      > "${log_file}" 2>&1
  local exit_code=$?
  set -e

  # Parsear y anexar CSV
  parse_and_append_csv "${log_file}" "${csv_file}" "${solver}" "${model_base}" "${data_base}"

  # Mensaje de estado
  if [[ ${exit_code} -eq 0 ]]; then
    echo "      OK -> ${log_file}"
  else
    echo "      WARN (exit ${exit_code}) -> ${log_file}"
  fi
}

# ==========================================================
# MAIN
# ==========================================================

ensure_dirs

# Validaciones mínimas
if [[ ${#ALL_MODELS[@]} -eq 0 ]]; then
  echo "No se encontraron modelos en ${ROOT_DIR}/jobshop_search_*.mzn"
  exit 1
fi

shopt -s nullglob
DZN_FILES=( "${TESTS_DIR}"/data*.dzn )
if [[ ${#DZN_FILES[@]} -eq 0 ]]; then
  echo "No se encontraron .dzn en ${TESTS_DIR}/"
  exit 1
fi
shopt -u nullglob

# Determina qué solvers ejecutar
if [[ -n "${SELECTED_SOLVER}" ]]; then
  SOLVERS=("${SELECTED_SOLVER}")
else
  SOLVERS=("${ALL_SOLVERS[@]}")
fi

# Determina qué modelos ejecutar
if [[ -n "${SELECTED_MODEL}" ]]; then
  MODEL_FILE="${ROOT_DIR}/jobshop_search_${SELECTED_MODEL}.mzn"
  if [[ ! -f "${MODEL_FILE}" ]]; then
    echo "ERROR: No existe ${MODEL_FILE}"
    exit 1
  fi
  MODELOS=("${MODEL_FILE}")
else
  MODELOS=("${ALL_MODELS[@]}")
fi

echo "MiniZinc: ${MINIZINC_BIN}"
echo "Solvers:  ${SOLVERS[*]}"
echo "Modelos:  ${#MODELOS[@]} -> $(printf '%s ' "${MODELOS[@]##*/}")"
echo "Datasets: ${#DZN_FILES[@]} -> $(printf '%s ' "${DZN_FILES[@]##*/}")"
echo "Tiempo límite: ${TIME_LIMIT_MS} ms | Seed: ${RANDOM_SEED}"
[[ -n "${UB_END}" ]] && echo "Cota superior end: ${UB_END}"
[[ -n "${ALL_SOLUTIONS_FLAG}" ]] && echo "Imprimiendo TODAS las soluciones (-a)"

echo "=========================================================="

for solver in "${SOLVERS[@]}"; do
  echo "=== Solver: ${solver} ==================================="
  for model in "${MODELOS[@]}"; do
    for dzn in "${DZN_FILES[@]}"; do
      run_one "${solver}" "${model}" "${dzn}"
    done
  done
done

echo "=========================================================="
echo "Listo. Revisa resultados bajo: ${OUTPUT_DIR}/results/"
echo "  - Logs:   results/<solver>/<modelo>/<data>.log"
echo "  - CSV:    results/<solver>/<modelo>/summary_<modelo>.csv"
