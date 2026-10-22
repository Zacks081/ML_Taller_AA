-- Módulo 0 · Fechas inconsistentes en orders (el orden lógico es
-- compra → aprobación → entrega al transportador → entrega al cliente)
UNPIVOT (
    SELECT
        sum((order_approved_at             < order_purchase_timestamp)::INT)      AS aprobacion_antes_de_compra,
        sum((order_delivered_carrier_date  < order_purchase_timestamp)::INT)      AS transportador_antes_de_compra,
        sum((order_delivered_carrier_date  < order_approved_at)::INT)             AS transportador_antes_de_aprobacion,
        sum((order_delivered_customer_date < order_purchase_timestamp)::INT)      AS entrega_antes_de_compra,
        sum((order_delivered_customer_date < order_approved_at)::INT)             AS entrega_antes_de_aprobacion,
        sum((order_delivered_customer_date < order_delivered_carrier_date)::INT)  AS entrega_antes_de_transportador,
        sum((order_estimated_delivery_date < order_purchase_timestamp)::INT)      AS estimada_antes_de_compra,
        sum((order_status = 'delivered'
             AND order_delivered_customer_date IS NULL)::INT)                     AS entregada_sin_fecha_de_entrega,
        sum((order_status <> 'delivered'
             AND order_delivered_customer_date IS NOT NULL)::INT)                 AS fecha_de_entrega_sin_estado_entregada
    FROM orders
)
ON COLUMNS(*)
INTO NAME regla VALUE ordenes;
