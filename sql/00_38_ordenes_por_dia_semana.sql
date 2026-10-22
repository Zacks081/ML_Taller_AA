-- Módulo 0 · Promedio de órdenes por día de la semana (incluye los días sin órdenes)
-- Parámetros: ? = inicio (incluido), ? = fin (excluido)
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
    isodow(c.dia)                                     AS num_dia,
    CASE isodow(c.dia)
        WHEN 1 THEN 'Lunes'  WHEN 2 THEN 'Martes'  WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sábado'
        ELSE 'Domingo'
    END                                               AS dia_semana,
    round(avg(coalesce(n.ordenes, 0)), 1)             AS ordenes_promedio
FROM calendario AS c
LEFT JOIN conteo AS n USING (dia)
GROUP BY ALL
ORDER BY num_dia;
