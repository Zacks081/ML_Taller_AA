-- Módulo 0 · Distribución geográfica: órdenes por estado del cliente, vendedores por estado
-- y tasa de retraso por estado del cliente
WITH clientes AS (
    SELECT
        customer_state                                                       AS estado,
        count(*)                                                             AS ordenes,
        round(100.0 * avg((order_delivered_customer_date::DATE
                           > order_estimated_delivery_date::DATE)::INT)
              FILTER (WHERE entregada), 2)                                   AS pct_tarde
    FROM ordenes_validas
    GROUP BY customer_state
),
vendedores AS (
    SELECT seller_state AS estado, count(*) AS vendedores
    FROM sellers
    GROUP BY seller_state
)
SELECT
    coalesce(c.estado, v.estado)   AS estado,
    coalesce(c.ordenes, 0)         AS ordenes_clientes,
    coalesce(v.vendedores, 0)      AS vendedores,
    c.pct_tarde
FROM clientes AS c
FULL JOIN vendedores AS v USING (estado)
ORDER BY ordenes_clientes DESC;
