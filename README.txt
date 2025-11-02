# README

ESQUEMA:

Se presentan los modelos y ejemplos en MiniZinc (.mzn) y datos de instancia (.dzn) organizados por carpetas según el problema de Job Shop.

Carpetas y archivos:

- `jobshop_maintenance/JobShop/`
	- `JobShopMantenimiento.mzn` : Modelo MiniZinc para el problema: Job Shop con Mantenimiento Preventivo.
	- `JobShop_Prueba1-10_Mantenimiento.dzn` : 10 instancias de prueba para el modelo de mantenimiento.

- `jobshop_op_limit/`
	- `jobshop_search_1.mzn` : Job Shop con Operarios Limitados (Estrategia 1 - Búsqueda libre).
	- `jobshop_search_2.mzn` : Job Shop con Operarios Limitados (Estrategia 2 - dom_w_deg para tiempos).
	- `jobshop_search_3.mzn` : Job Shop con Operarios Limitados (Estrategia 3 - Operarios primero).
	- `tests/data00-10.dzn` : 11 instancias de prueba con complejidad creciente.
	- `run_jobshop_tests.sh` : Script para pruebas automáticas con múltiples solvers(Opcional/Solo Linux).

- `jobshop_op_limit_skills/`
	- (En desarrollo)

EJECUCIÓN:

- Ejecución normal mediante IDE MiniZinc:
	- Abrir el archivo .mzn deseado (por ejemplo, `jobshop_search_1.mzn`).
	- Cargar el archivo .dzn correspondiente desde la carpeta `tests/` (por ejemplo, `data00.dzn`).
	- Seleccionar el solver deseado y ejecutar.


- Ejecución automática de pruebas en `jobshop_op_limit/`(Opcional/Solo Linux):
	```bash
	cd jobshop_op_limit
	bash run_jobshop_tests.sh <options(-h para mostrar las opciones)>
	```

