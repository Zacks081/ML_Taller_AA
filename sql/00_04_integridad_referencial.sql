-- Módulo 0 · Integridad referencial: registros cuya llave foránea no encuentra pareja
SELECT 'orders sin cliente' AS chequeo,
       count(*) AS registros
FROM orders AS o
WHERE NOT EXISTS (SELECT 1 FROM customers AS c WHERE c.customer_id = o.customer_id)
UNION ALL
SELECT 'orders sin ítems', count(*)
FROM orders AS o
WHERE NOT EXISTS (SELECT 1 FROM order_items AS i WHERE i.order_id = o.order_id)
UNION ALL
SELECT 'orders sin pagos', count(*)
FROM orders AS o
WHERE NOT EXISTS (SELECT 1 FROM order_payments AS p WHERE p.order_id = o.order_id)
UNION ALL
SELECT 'orders sin reseña', count(*)
FROM orders AS o
WHERE NOT EXISTS (SELECT 1 FROM order_reviews AS r WHERE r.order_id = o.order_id)
UNION ALL
SELECT 'order_items sin producto', count(*)
FROM order_items AS i
WHERE NOT EXISTS (SELECT 1 FROM products AS p WHERE p.product_id = i.product_id)
UNION ALL
SELECT 'order_items sin vendedor', count(*)
FROM order_items AS i
WHERE NOT EXISTS (SELECT 1 FROM sellers AS s WHERE s.seller_id = i.seller_id)
UNION ALL
SELECT 'order_reviews sin orden', count(*)
FROM order_reviews AS r
WHERE NOT EXISTS (SELECT 1 FROM orders AS o WHERE o.order_id = r.order_id);
