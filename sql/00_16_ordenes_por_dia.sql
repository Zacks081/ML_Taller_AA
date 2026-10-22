-- Módulo 0 · Órdenes por día de compra, incluyendo los días sin órdenes
-- Parámetros: ? = fecha inicial (incluida), ? = fecha final (excluida)
WITH calendario AS (
    SELECT range::DATE AS dia
    FROM range(?::TIMESTAMP, ?::TIMESTAMP, INTERVAL 1 DAY)
),
conteo AS (
    SELECT order_purchase_timestamp::DATE AS dia, count(*) AS ordenes
    FROM orders
    GROUP BY dia
)
SELECT
    c.dia,
    coalesce(n.ordenes, 0) AS ordenes
FROM calendario AS c
LEFT JOIN conteo AS n USING (dia)
ORDER BY c.dia;
