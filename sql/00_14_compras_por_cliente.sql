-- Módulo 0 · Distribución del número de órdenes por persona (customer_unique_id)
WITH por_persona AS (
    SELECT c.customer_unique_id, count(*) AS ordenes
    FROM orders AS o
    JOIN customers AS c USING (customer_id)
    GROUP BY c.customer_unique_id
)
SELECT
    ordenes                                                AS ordenes_por_persona,
    count(*)                                               AS personas,
    round(100.0 * count(*) / sum(count(*)) OVER (), 2)     AS pct_personas
FROM por_persona
GROUP BY ordenes
ORDER BY ordenes;
