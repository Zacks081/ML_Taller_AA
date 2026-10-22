-- Módulo 0 · Órdenes por mes de compra (cobertura temporal completa del dataset)
SELECT
    date_trunc('month', order_purchase_timestamp)::DATE   AS mes,
    count(*)                                              AS ordenes,
    sum((order_status = 'delivered')::INT)                AS entregadas
FROM orders
GROUP BY mes
ORDER BY mes;
