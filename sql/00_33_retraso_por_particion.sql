-- Módulo 0 · Tasa de retraso en cada partición temporal fija del Módulo A
-- Parámetros: ? inicio entrenamiento, ? inicio validación, ? inicio prueba, ? fin prueba (excluido)
WITH cortes AS (
    SELECT ?::TIMESTAMP AS ini_train, ?::TIMESTAMP AS ini_val,
           ?::TIMESTAMP AS ini_test,  ?::TIMESTAMP AS fin_test
),
base AS (
    SELECT
        CASE
            WHEN o.order_purchase_timestamp >= k.ini_train AND o.order_purchase_timestamp < k.ini_val  THEN '1. Entrenamiento'
            WHEN o.order_purchase_timestamp >= k.ini_val   AND o.order_purchase_timestamp < k.ini_test THEN '2. Validación'
            WHEN o.order_purchase_timestamp >= k.ini_test  AND o.order_purchase_timestamp < k.fin_test THEN '3. Prueba'
        END                                                                          AS particion,
        (o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE)::INT AS tarde,
        date_diff('day', o.order_purchase_timestamp::DATE, o.order_estimated_delivery_date::DATE)  AS dias_prometidos,
        date_diff('day', o.order_purchase_timestamp::DATE, o.order_delivered_customer_date::DATE)  AS dias_entrega
    FROM ordenes_validas AS o
    CROSS JOIN cortes AS k
    WHERE o.entregada
)
SELECT
    particion,
    count(*)                          AS ordenes,
    sum(tarde)                        AS ordenes_tarde,
    round(100.0 * avg(tarde), 2)      AS pct_tarde,
    round(avg(dias_prometidos), 1)    AS dias_prometidos_prom,
    round(avg(dias_entrega), 1)       AS dias_entrega_prom
FROM base
WHERE particion IS NOT NULL
GROUP BY particion
ORDER BY particion;
