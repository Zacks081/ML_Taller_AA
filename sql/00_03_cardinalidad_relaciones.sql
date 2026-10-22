-- Módulo 0 · Cardinalidad de las relaciones con la tabla orders
-- Para cada relación 1:N se mide cuántas filas hijas tiene cada orden (o cada padre).
WITH por_orden_items   AS (SELECT order_id, count(*) AS n FROM order_items GROUP BY order_id),
     por_orden_pagos   AS (SELECT order_id, count(*) AS n FROM order_payments GROUP BY order_id),
     por_orden_resenas AS (SELECT order_id, count(*) AS n FROM order_reviews GROUP BY order_id),
     por_orden_vend    AS (SELECT order_id, count(DISTINCT seller_id) AS n FROM order_items GROUP BY order_id),
     por_cliente_real  AS (SELECT c.customer_unique_id, count(*) AS n
                           FROM orders AS o JOIN customers AS c USING (customer_id)
                           GROUP BY c.customer_unique_id),
     por_orden_cliente AS (SELECT o.order_id, count(*) AS n
                           FROM orders AS o JOIN customers AS c USING (customer_id)
                           GROUP BY o.order_id),
     por_prefijo_geo   AS (SELECT geolocation_zip_code_prefix, count(*) AS n
                           FROM geolocation GROUP BY geolocation_zip_code_prefix)
SELECT 'orders → customers (customer_id)' AS relacion, 'orden' AS padre,
       count(*) AS padres, round(avg(n), 3) AS prom_hijos, max(n) AS max_hijos,
       sum((n > 1)::INT) AS padres_con_varios_hijos
FROM por_orden_cliente
UNION ALL
SELECT 'orders → order_items', 'orden', count(*), round(avg(n), 3), max(n), sum((n > 1)::INT) FROM por_orden_items
UNION ALL
SELECT 'orders → order_payments', 'orden', count(*), round(avg(n), 3), max(n), sum((n > 1)::INT) FROM por_orden_pagos
UNION ALL
SELECT 'orders → order_reviews', 'orden', count(*), round(avg(n), 3), max(n), sum((n > 1)::INT) FROM por_orden_resenas
UNION ALL
SELECT 'orders → sellers (vía order_items)', 'orden', count(*), round(avg(n), 3), max(n), sum((n > 1)::INT) FROM por_orden_vend
UNION ALL
SELECT 'customer_unique_id → orders', 'cliente real', count(*), round(avg(n), 3), max(n), sum((n > 1)::INT) FROM por_cliente_real
UNION ALL
SELECT 'prefijo postal → geolocation', 'prefijo', count(*), round(avg(n), 3), max(n), sum((n > 1)::INT) FROM por_prefijo_geo;
