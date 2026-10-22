-- Módulo 0 · Distribución (conteo por número de días) del tiempo de entrega y del retraso
WITH entregas AS (
    SELECT
        date_diff('day', order_purchase_timestamp::DATE, order_delivered_customer_date::DATE)      AS dias_entrega,
        date_diff('day', order_estimated_delivery_date::DATE, order_delivered_customer_date::DATE) AS dias_retraso
    FROM ordenes_validas
    WHERE entregada
)
SELECT 'dias_entrega' AS medida, dias_entrega AS dias, count(*) AS ordenes
FROM entregas GROUP BY dias_entrega
UNION ALL
SELECT 'dias_retraso', dias_retraso, count(*)
FROM entregas GROUP BY dias_retraso
ORDER BY medida, dias;
