-- Módulo 0 · Órdenes sin ítems, por estado
SELECT
    o.order_status   AS estado,
    count(*)         AS ordenes_sin_items
FROM orders AS o
WHERE NOT EXISTS (SELECT 1 FROM order_items AS i WHERE i.order_id = o.order_id)
GROUP BY o.order_status
ORDER BY ordenes_sin_items DESC;
