-- Módulo 0 · Estado de las órdenes por semana de compra (para ver la censura al final)
-- Parámetro: ? = fecha desde la cual se analiza
SELECT
    date_trunc('week', order_purchase_timestamp)::DATE                       AS semana,
    count(*)                                                                 AS ordenes,
    round(100.0 * avg((order_status = 'delivered')::INT), 2)                 AS pct_entregadas,
    round(100.0 * avg((order_status IN ('shipped', 'invoiced', 'processing',
                                        'approved', 'created'))::INT), 2)    AS pct_en_proceso,
    round(100.0 * avg((order_status IN ('canceled', 'unavailable'))::INT), 2) AS pct_canceladas
FROM orders
WHERE order_purchase_timestamp >= ?
GROUP BY semana
ORDER BY semana;
