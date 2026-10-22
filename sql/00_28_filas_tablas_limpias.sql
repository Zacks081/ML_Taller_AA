-- Módulo 0 · Número de filas de cada tabla limpia
SELECT 'geo_prefijo' AS tabla, count(*) AS filas FROM geo_prefijo
UNION ALL SELECT 'productos_limpios', count(*) FROM productos_limpios
UNION ALL SELECT 'ordenes_validas',   count(*) FROM ordenes_validas;
