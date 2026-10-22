-- Módulo 0 · Verificación: después de la limpieza, cada problema detectado debe quedar en 0
-- Requiere 00_20, 00_21, 00_22 y 00_23
SELECT 'geo_prefijo'       AS tabla, 'Prefijos con menos de 5 dígitos'                 AS chequeo, count(*) AS registros
FROM geo_prefijo WHERE length(prefijo) < 5
UNION ALL
SELECT 'geo_prefijo',       'Prefijos repetidos (debe haber una fila por prefijo)', count(*) - count(DISTINCT prefijo)
FROM geo_prefijo
UNION ALL
SELECT 'geo_prefijo',       'Coordenadas fuera de Brasil',                          count(*)
FROM geo_prefijo WHERE lat NOT BETWEEN -34 AND 5.5 OR lng NOT BETWEEN -74 AND -34
UNION ALL
SELECT 'productos_limpios', 'Productos sin categoría',                              count(*)
FROM productos_limpios WHERE categoria_pt IS NULL OR categoria_en IS NULL
UNION ALL
SELECT 'productos_limpios', 'Categorías con nombre sin traducción',                 count(*)
FROM productos_limpios WHERE categoria_en = 'unknown' AND categoria_pt <> 'sin_categoria'
UNION ALL
SELECT 'productos_limpios', 'Productos con peso = 0 g',                             count(*)
FROM productos_limpios WHERE peso_g = 0
UNION ALL
SELECT 'ordenes_validas',   'Compradas fuera del período útil',                     count(*)
FROM ordenes_validas WHERE NOT en_periodo_util
UNION ALL
SELECT 'ordenes_validas',   'Órdenes sin ítems',                                    count(*)
FROM ordenes_validas WHERE NOT tiene_items
UNION ALL
SELECT 'ordenes_validas',   'Entrega al cliente antes que al transportador',        count(*)
FROM ordenes_validas WHERE order_delivered_customer_date < order_delivered_carrier_date
UNION ALL
SELECT 'ordenes_validas',   'Entrega al cliente antes de la aprobación',            count(*)
FROM ordenes_validas WHERE order_delivered_customer_date < order_approved_at
UNION ALL
SELECT 'ordenes_validas',   'Órdenes repetidas',                                    count(*) - count(DISTINCT order_id)
FROM ordenes_validas;
