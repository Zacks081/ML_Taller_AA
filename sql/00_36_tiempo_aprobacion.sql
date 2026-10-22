-- Módulo 0 · Tiempo entre la compra y la aprobación (momento en que se usa el modelo A)
SELECT
    count(*)                                                                 AS ordenes,
    round(quantile_cont(date_diff('minute', order_purchase_timestamp,
                                  order_approved_at) / 60.0, 0.50), 2)       AS horas_p50,
    round(quantile_cont(date_diff('minute', order_purchase_timestamp,
                                  order_approved_at) / 60.0, 0.90), 2)       AS horas_p90,
    round(quantile_cont(date_diff('minute', order_purchase_timestamp,
                                  order_approved_at) / 60.0, 0.99), 2)       AS horas_p99,
    round(100.0 * avg((order_approved_at::DATE
                       = order_purchase_timestamp::DATE)::INT), 2)           AS pct_aprobadas_mismo_dia
FROM ordenes_validas
WHERE entregada AND tiene_aprobacion;
