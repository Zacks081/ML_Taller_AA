# Taller Olist — Aprendizaje Automático (SI7009, EAFIT 2026-2)

Módulo 0 (datos, calidad y EDA) y Módulo A (clasificación de entregas tardías)
sobre el dataset Olist cargado en DuckDB.

**Integrantes:** Nombre 1 · Nombre 2 · Nombre 3

## Estructura

```
notebooks/   00_datos.ipynb, A_clasificacion.ipynb
sql/         consultas leídas desde los notebooks (00_* y A_*)
scripts/     build_olist_duckdb.py (script del curso)
data/        olist.duckdb (no se versiona)
informe/     informe final en PDF
```

## Cómo reproducir

1. Python 3.13 y un entorno virtual en la raíz del repo:

```bash
   python -m venv .venv
   # Windows: .venv\Scripts\activate   |   macOS/Linux: source .venv/bin/activate
   pip install -r requirements.txt
```

2. Construir la base (descarga el dataset desde Kaggle):

```bash
   python scripts/build_olist_duckdb.py --out data/olist.duckdb
```

Si Kaggle pide credenciales, descargue el zip desde
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce, descomprímalo y use
`--csv-dir ruta/a/csvs`. 3. Ejecutar los notebooks en orden: `00_datos` → `A_clasificacion`.

## Reglas del taller que cumple el código

- Toda la lectura de datos es con SQL sobre `olist.duckdb` (conexión `read_only=True`).
- Joins, filtros y agregados se resuelven en SQL; las fechas de corte van como parámetro `?`.
- Semilla fija (`SEED = 42`) y rutas relativas a la raíz del repo.
