-- Módulo 0 · Qué contiene cada tabla limpia (columnas y tipos) que recibe el Módulo A
SELECT
    table_name                       AS tabla,
    count(*)                         AS columnas,
    string_agg(column_name, ', ' ORDER BY column_index) AS lista_columnas
FROM duckdb_columns()
WHERE database_name = 'temp'
  AND table_name IN ('geo_prefijo', 'productos_limpios', 'ordenes_validas')
GROUP BY table_name
ORDER BY table_name;
