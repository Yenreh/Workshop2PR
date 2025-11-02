# Job Shop con Operarios Limitados

## Ejecución de Tests

### Uso básico

```bash
bash run_jobshop_tests.sh [OPCIONES]
```

### Opciones

- `-s, --solver SOLVER` : Especifica el solver (chuffed, gecode, highs)
- `-m, --model NUM` : Número de modelo (1, 2, 3)
- `-h, --help` : Muestra ayuda

### Ejemplos

```bash
# Ejecutar modelo 1 con highs
bash run_jobshop_tests.sh -s highs -m 1

# Ejecutar modelo 1 con chuffed
bash run_jobshop_tests.sh -s chuffed -m 1

# Ejecutar todos los modelos con gecode
bash run_jobshop_tests.sh -s gecode

# Ejecutar todos los solvers y modelos
bash run_jobshop_tests.sh
```

## Resultados

Los resultados se guardan en:
- **Logs**: `output/results/<solver>/<modelo>/<data>.log`
- **CSV**: `output/results/<solver>/<modelo>/summary_<modelo>.csv`

## Modelos

- `jobshop_search_1.mzn` - Estrategia de búsqueda 1
- `jobshop_search_2.mzn` - Estrategia de búsqueda 2
- `jobshop_search_3.mzn` - Estrategia de búsqueda 3

## Datasets

Los archivos de datos están en `tests/data*.dzn` (data00.dzn a data10.dzn)
