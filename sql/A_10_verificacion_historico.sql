-- Módulo A. Verificación del histórico del vendedor.
-- Para una muestra fija de órdenes se cuenta "a mano" (con un join directo, sin ASOF) cuántas
-- órdenes del mismo vendedor estaban entregadas antes de la aprobación, y se compara con lo
-- que calculó A_07. Si todo está bien, las dos cuentas coinciden en todas las órdenes.
WITH muestra AS (
    SELECT order_id, fecha_aprobacion
    FROM poblacion_a
    USING SAMPLE reservoir(300 ROWS) REPEATABLE (42)
),
pares AS (
    SELECT DISTINCT m.order_id, m.fecha_aprobacion, i.seller_id
    FROM muestra AS m
    JOIN order_items AS i USING (order_id)
),
conteo_directo AS (
    SELECT
        p.order_id,
        p.seller_id,
        count(DISTINCT o.order_id) AS n_previas
    FROM pares AS p
    LEFT JOIN order_items AS i2 ON i2.seller_id = p.seller_id
    LEFT JOIN ordenes_validas AS o
           ON o.order_id = i2.order_id
          AND o.entregada
          AND o.order_delivered_customer_date < p.fecha_aprobacion
    GROUP BY p.order_id, p.seller_id
),
por_orden AS (
    SELECT order_id, min(n_previas) AS n_previas_directo
    FROM conteo_directo
    GROUP BY order_id
)
SELECT
    count(*)                                                        AS ordenes_revisadas,
    sum((d.n_previas_directo = h.vendedor_n_entregas_previas)::INT) AS ordenes_que_coinciden
FROM por_orden AS d
JOIN historico_vendedor AS h USING (order_id);
