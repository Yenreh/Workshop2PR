# README

ESQUEMA:

Se presentan los modelos y ejemplos en MiniZinc (.mzn) y datos de instancia (.dzn) organizados por carpetas según el problema de Job Shop.

Carpetas y archivos:

- `jobshop_maintenance/`
	- `JobShopMantenimiento.mzn` : Modelo MiniZinc para el problema: Job Shop con Mantenimiento Preventivo.
	- `tests/JobShop_Prueba1-10_Mantenimiento.dzn` : 10 instancias de prueba para el modelo de mantenimiento.

- `jobshop_op_limit/`
	- `jobshop_search_1.mzn` : Job Shop con Operarios Limitados (Estrategia 1 - Búsqueda libre).
	- `jobshop_search_2.mzn` : Job Shop con Operarios Limitados (Estrategia 2 - dom_w_deg para tiempos).
	- `jobshop_search_3.mzn` : Job Shop con Operarios Limitados (Estrategia 3 - Operarios primero).
	- `tests/data00-10.dzn` : 11 instancias de prueba con complejidad creciente.

- `jobshop_op_limit_skills/`
	- `jobshop_workers_1.mzn` : Job Shop con Operarios Limitados (Estrategia 1 - Búsqueda libre).
	- `jobshop_workers_2.mzn` : Job Shop con Operarios Limitados (Estrategia 2 - dom_w_deg para tiempos).
	- `jobshop_workers_3.mzn` : Job Shop con Operarios Limitados (Estrategia 3 - Operarios primero).
	- `tests/data_01-10.dzn` : 11 instancias de prueba con complejidad creciente.

EJECUCIÓN:

- Ejecución normal mediante IDE MiniZinc:
	- Abrir el archivo .mzn deseado (por ejemplo, `jobshop_search_1.mzn`).
	- Cargar el archivo .dzn correspondiente desde la carpeta `tests/` (por ejemplo, `data00.dzn`).
	- Seleccionar el solver deseado y ejecutar.
    - Para jobshop_maintenance, se debe tener en cuenta que para cambiar de estrategia de búsqueda se debe comentar/descomentar la que se quiera probar.


