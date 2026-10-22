-- Módulo 0 · Tasa de retraso, plazo prometido y tiempo real de entrega por mes de compra
SELECT
    date_trunc('month', order_purchase_timestamp)::DATE                       AS mes,
    count(*)                                                                  AS ordenes_entregadas,
    round(100.0 * avg((order_delivered_customer_date::DATE
                       > order_estimated_delivery_date::DATE)::INT), 2)       AS pct_tarde,
    round(avg(date_diff('day', order_purchase_timestamp::DATE,
                        order_estimated_delivery_date::DATE)), 1)             AS dias_prometidos_prom,
    round(avg(date_diff('day', order_purchase_timestamp::DATE,
                        order_delivered_customer_date::DATE)), 1)             AS dias_entrega_prom
FROM ordenes_validas
WHERE entregada
GROUP BY mes
ORDER BY mes;
