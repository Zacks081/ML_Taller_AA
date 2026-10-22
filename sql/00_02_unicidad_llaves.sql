-- Módulo 0 · Unicidad de las llaves de cada tabla
-- Una llave es única si el número de valores distintos es igual al número de filas.
WITH llaves AS (
    SELECT 'orders' AS tabla, 'order_id' AS llave,
           count(*) AS filas, count(DISTINCT order_id) AS distintos
    FROM orders
    UNION ALL
    SELECT 'customers', 'customer_id', count(*), count(DISTINCT customer_id) FROM customers
    UNION ALL
    SELECT 'customers', 'customer_unique_id', count(*), count(DISTINCT customer_unique_id) FROM customers
    UNION ALL
    SELECT 'sellers', 'seller_id', count(*), count(DISTINCT seller_id) FROM sellers
    UNION ALL
    SELECT 'products', 'product_id', count(*), count(DISTINCT product_id) FROM products
    UNION ALL
    SELECT 'order_items', '(order_id, order_item_id)', count(*), count(DISTINCT (order_id, order_item_id)) FROM order_items
    UNION ALL
    SELECT 'order_payments', '(order_id, payment_sequential)', count(*), count(DISTINCT (order_id, payment_sequential)) FROM order_payments
    UNION ALL
    SELECT 'order_reviews', 'review_id', count(*), count(DISTINCT review_id) FROM order_reviews
    UNION ALL
    SELECT 'order_reviews', '(review_id, order_id)', count(*), count(DISTINCT (review_id, order_id)) FROM order_reviews
    UNION ALL
    SELECT 'geolocation', 'geolocation_zip_code_prefix', count(*), count(DISTINCT geolocation_zip_code_prefix) FROM geolocation
    UNION ALL
    SELECT 'category_translation', 'product_category_name', count(*), count(DISTINCT product_category_name) FROM category_translation
)
SELECT
    tabla,
    llave,
    filas,
    distintos,
    filas - distintos     AS filas_repetidas,
    filas = distintos     AS es_unica
FROM llaves;
