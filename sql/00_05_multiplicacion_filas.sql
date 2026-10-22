-- Módulo 0 · Demostración: un join ingenuo entre tablas 1:N multiplica filas
-- Unir orders con order_items y order_payments a la vez repite cada pago por cada ítem,
-- así que la suma de pagos queda inflada. La solución es agregar cada tabla por order_id
-- ANTES de unirla.
SELECT
    'Join ingenuo (orders × items × payments)'  AS metodo,
    count(*)                                     AS filas,
    count(DISTINCT o.order_id)                   AS ordenes,
    round(sum(p.payment_value), 2)               AS suma_pagos
FROM orders AS o
JOIN order_items    AS i USING (order_id)
JOIN order_payments AS p USING (order_id)

UNION ALL

SELECT
    'Agregar por order_id antes de unir',
    count(*),
    count(DISTINCT o.order_id),
    round(sum(p.pago_total), 2)
FROM orders AS o
LEFT JOIN (SELECT order_id, count(*) AS n_items
           FROM order_items GROUP BY order_id)            AS i USING (order_id)
LEFT JOIN (SELECT order_id, sum(payment_value) AS pago_total
           FROM order_payments GROUP BY order_id)         AS p USING (order_id)

UNION ALL

SELECT
    'Referencia: suma directa de order_payments',
    count(*),
    count(DISTINCT order_id),
    round(sum(payment_value), 2)
FROM order_payments;
