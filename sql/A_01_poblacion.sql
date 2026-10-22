-- Módulo A. Población, variable objetivo y partición temporal.
-- Órdenes válidas entregadas, con fecha de entrega y de aprobación, compradas entre
-- el inicio de entrenamiento y el fin de prueba.
-- El objetivo vale 1 si la entrega real fue después de la fecha estimada (por día calendario).
-- Parámetros: inicio entrenamiento, inicio validación, inicio prueba, fin prueba (excluido).
CREATE OR REPLACE TEMP TABLE poblacion_a AS
WITH cortes AS (
    SELECT ?::TIMESTAMP AS ini_train, ?::TIMESTAMP AS ini_val,
           ?::TIMESTAMP AS ini_test,  ?::TIMESTAMP AS fin_test
)
SELECT
    o.order_id,
    o.customer_unique_id,
    o.customer_state,
    o.customer_prefijo,
    o.order_purchase_timestamp       AS fecha_compra,
    o.order_approved_at              AS fecha_aprobacion,
    o.order_estimated_delivery_date  AS fecha_estimada,
    CASE
        WHEN o.order_purchase_timestamp < k.ini_val  THEN 'train'
        WHEN o.order_purchase_timestamp < k.ini_test THEN 'val'
        ELSE 'test'
    END AS particion,
    (o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE)::INT AS tarde
FROM ordenes_validas AS o
CROSS JOIN cortes AS k
WHERE o.entregada
  AND o.tiene_aprobacion
  AND o.order_purchase_timestamp >= k.ini_train
  AND o.order_purchase_timestamp <  k.fin_test;
