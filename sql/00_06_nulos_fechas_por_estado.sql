-- Módulo 0 · Faltantes en las marcas de tiempo de orders, por estado de la orden
SELECT
    order_status                                             AS estado,
    count(*)                                                 AS ordenes,
    sum((order_approved_at             IS NULL)::INT)        AS sin_aprobacion,
    sum((order_delivered_carrier_date  IS NULL)::INT)        AS sin_entrega_transportador,
    sum((order_delivered_customer_date IS NULL)::INT)        AS sin_entrega_cliente,
    sum((order_estimated_delivery_date IS NULL)::INT)        AS sin_fecha_estimada
FROM orders
GROUP BY order_status
ORDER BY ordenes DESC;
