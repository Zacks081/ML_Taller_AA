-- Módulo 0 · ¿Los pagos cuadran con precio + flete de los ítems?
-- Se agrega cada tabla por order_id antes de unir (evita multiplicar filas).
-- Tolerancia de 1 centavo para errores de redondeo.
WITH items AS (
    SELECT order_id, sum(price + freight_value) AS total_items
    FROM order_items
    GROUP BY order_id
),
pagos AS (
    SELECT order_id, sum(payment_value) AS total_pagado
    FROM order_payments
    GROUP BY order_id
),
comparacion AS (
    SELECT
        i.order_id,
        p.total_pagado - i.total_items AS diferencia,
        CASE
            WHEN p.order_id IS NULL                          THEN 'sin pagos'
            WHEN abs(p.total_pagado - i.total_items) <= 0.01 THEN 'cuadra'
            WHEN p.total_pagado > i.total_items              THEN 'pago mayor que ítems'
            ELSE                                                  'pago menor que ítems'
        END AS resultado
    FROM items AS i
    LEFT JOIN pagos AS p USING (order_id)
)
SELECT
    resultado,
    count(*)                                   AS ordenes,
    round(100.0 * count(*) / sum(count(*)) OVER (), 3) AS pct_ordenes,
    round(median(diferencia), 2)               AS mediana_diferencia,
    round(max(abs(diferencia)), 2)             AS max_diferencia_abs
FROM comparacion
GROUP BY resultado
ORDER BY ordenes DESC;
