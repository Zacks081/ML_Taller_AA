-- Módulo 0 · Resumen de tiempos de entrega y retraso (órdenes válidas entregadas)
-- Retraso = fecha real de entrega − fecha estimada, comparadas por día calendario.
WITH entregas AS (
    SELECT
        date_diff('day', order_purchase_timestamp::DATE, order_delivered_customer_date::DATE)      AS dias_entrega,
        date_diff('day', order_purchase_timestamp::DATE, order_estimated_delivery_date::DATE)      AS dias_prometidos,
        date_diff('day', order_estimated_delivery_date::DATE, order_delivered_customer_date::DATE) AS dias_retraso
    FROM ordenes_validas
    WHERE entregada
)
SELECT 'Días de compra a entrega' AS medida,
       round(avg(dias_entrega), 1) AS promedio,
       quantile_cont(dias_entrega, 0.05) AS p05, quantile_cont(dias_entrega, 0.25) AS p25,
       quantile_cont(dias_entrega, 0.50) AS p50, quantile_cont(dias_entrega, 0.75) AS p75,
       quantile_cont(dias_entrega, 0.95) AS p95, max(dias_entrega) AS maximo
FROM entregas
UNION ALL
SELECT 'Días prometidos (estimada − compra)', round(avg(dias_prometidos), 1),
       quantile_cont(dias_prometidos, 0.05), quantile_cont(dias_prometidos, 0.25),
       quantile_cont(dias_prometidos, 0.50), quantile_cont(dias_prometidos, 0.75),
       quantile_cont(dias_prometidos, 0.95), max(dias_prometidos)
FROM entregas
UNION ALL
SELECT 'Días de retraso (entrega − estimada)', round(avg(dias_retraso), 1),
       quantile_cont(dias_retraso, 0.05), quantile_cont(dias_retraso, 0.25),
       quantile_cont(dias_retraso, 0.50), quantile_cont(dias_retraso, 0.75),
       quantile_cont(dias_retraso, 0.95), max(dias_retraso)
FROM entregas;
