-- Módulo 0 · Número de filas de cada tabla cargada en olist.duckdb
SELECT 'orders' AS tabla, count(*) AS filas FROM orders
UNION ALL SELECT 'order_items',          count(*) FROM order_items
UNION ALL SELECT 'order_payments',       count(*) FROM order_payments
UNION ALL SELECT 'order_reviews',        count(*) FROM order_reviews
UNION ALL SELECT 'customers',            count(*) FROM customers
UNION ALL SELECT 'sellers',              count(*) FROM sellers
UNION ALL SELECT 'products',             count(*) FROM products
UNION ALL SELECT 'geolocation',          count(*) FROM geolocation
UNION ALL SELECT 'category_translation', count(*) FROM category_translation;
