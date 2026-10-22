-- Módulo 0 · ¿Se retrasan más las órdenes que cruzan de estado?
-- Una orden es "misma UF" si TODOS sus vendedores están en el estado del cliente.
-- Se agrega order_items por orden antes de unir con las órdenes (sin multiplicar filas).
WITH ruta AS (
    SELECT
        i.order_id,
        bool_and(s.seller_state = o.customer_state) AS misma_uf
    FROM order_items AS i
    JOIN sellers AS s USING (seller_id)
    JOIN ordenes_validas AS o USING (order_id)
    GROUP BY i.order_id
)
SELECT
    CASE WHEN r.misma_uf THEN 'Vendedor y cliente en el mismo estado'
         ELSE 'Vendedor en otro estado' END                                  AS ruta,
    count(*)                                                                 AS ordenes_entregadas,
    round(100.0 * avg((o.order_delivered_customer_date::DATE
                       > o.order_estimated_delivery_date::DATE)::INT), 2)    AS pct_tarde,
    round(avg(date_diff('day', o.order_purchase_timestamp::DATE,
                        o.order_delivered_customer_date::DATE)), 1)          AS dias_entrega_prom
FROM ordenes_validas AS o
JOIN ruta AS r USING (order_id)
WHERE o.entregada
GROUP BY ruta
ORDER BY ruta;
