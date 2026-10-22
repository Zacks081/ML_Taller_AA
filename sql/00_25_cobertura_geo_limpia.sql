-- Módulo 0 · Cobertura de coordenadas después de limpiar geolocation y normalizar prefijos
-- Requiere 00_20_geo_prefijo.sql y 00_23_ordenes_validas.sql
SELECT
    'Órdenes válidas con coordenadas del cliente'   AS chequeo,
    count(*)                                        AS total,
    sum((g.prefijo IS NOT NULL)::INT)               AS con_coordenadas,
    round(100.0 * avg((g.prefijo IS NOT NULL)::INT), 2) AS pct_con_coordenadas
FROM ordenes_validas AS o
LEFT JOIN geo_prefijo AS g ON g.prefijo = o.customer_prefijo
UNION ALL
SELECT
    'Vendedores con coordenadas',
    count(*),
    sum((g.prefijo IS NOT NULL)::INT),
    round(100.0 * avg((g.prefijo IS NOT NULL)::INT), 2)
FROM sellers AS s
LEFT JOIN geo_prefijo AS g ON g.prefijo = lpad(s.seller_zip_code_prefix, 5, '0');
