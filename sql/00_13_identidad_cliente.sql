-- Módulo 0 · customer_id vs customer_unique_id
-- customer_id se genera por orden; customer_unique_id identifica a la persona.
SELECT
    count(*)                                      AS filas_customers,
    count(DISTINCT customer_id)                   AS customer_id_distintos,
    count(DISTINCT customer_unique_id)            AS personas_distintas,
    (SELECT count(*) FROM (
        SELECT customer_unique_id FROM customers
        GROUP BY customer_unique_id HAVING count(*) > 1))          AS personas_con_varias_ordenes,
    (SELECT count(*) FROM (
        SELECT customer_unique_id FROM customers
        GROUP BY customer_unique_id HAVING count(DISTINCT customer_state) > 1)) AS personas_en_varios_estados
FROM customers;
