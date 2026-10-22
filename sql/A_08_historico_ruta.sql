-- Módulo A. Histórico de la ruta (estado del vendedor a estado del cliente), sin fuga.
-- Misma lógica que el histórico del vendedor: solo cuentan órdenes de la misma ruta
-- entregadas antes de la aprobación de cada orden.
-- Parámetro: m, peso de la tasa global en el suavizado.
CREATE OR REPLACE TEMP TABLE historico_ruta AS
WITH entregas AS (
    SELECT DISTINCT
        s.seller_state || '-' || o.customer_state                               AS ruta,
        o.order_id,
        o.order_delivered_customer_date                                         AS fecha_entrega,
        (o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE)::INT AS tarde,
        date_diff('day', o.order_purchase_timestamp::DATE,
                  o.order_delivered_customer_date::DATE)                        AS dias_entrega
    FROM ordenes_validas AS o
    JOIN order_items AS i USING (order_id)
    JOIN sellers AS s USING (seller_id)
    WHERE o.entregada
),
acumulado_ruta AS (
    SELECT
        ruta,
        fecha_entrega,
        count(*)   OVER w AS n_previas,
        sum(tarde) OVER w AS tardes_previas,
        sum(dias_entrega) OVER w AS dias_previos
    FROM entregas
    WINDOW w AS (PARTITION BY ruta ORDER BY fecha_entrega)
),
acumulado_global AS (
    SELECT DISTINCT
        fecha_entrega,
        avg(tarde) OVER (ORDER BY fecha_entrega) AS tasa_global
    FROM (SELECT DISTINCT order_id, fecha_entrega, tarde FROM entregas)
),
pares AS (
    SELECT DISTINCT
        a.order_id,
        s.seller_state || '-' || a.customer_state AS ruta,
        a.fecha_aprobacion
    FROM poblacion_a AS a
    JOIN order_items AS i USING (order_id)
    JOIN sellers AS s USING (seller_id)
),
con_historico AS (
    SELECT
        p.order_id,
        coalesce(r.n_previas, 0)        AS n_previas,
        coalesce(r.tardes_previas, 0)   AS tardes_previas,
        r.dias_previos / r.n_previas    AS dias_entrega_prom,
        g.tasa_global
    FROM pares AS p
    ASOF LEFT JOIN acumulado_ruta AS r
        ON p.ruta = r.ruta AND p.fecha_aprobacion > r.fecha_entrega
    ASOF LEFT JOIN acumulado_global AS g
        ON p.fecha_aprobacion > g.fecha_entrega
)
SELECT
    order_id,
    min(n_previas)                                                        AS ruta_n_entregas_previas,
    max((tardes_previas + ?::DOUBLE * coalesce(tasa_global, 0))
        / (n_previas + ?::DOUBLE))                                        AS ruta_tasa_retraso,
    max(dias_entrega_prom)                                                AS ruta_dias_entrega_prom
FROM con_historico
GROUP BY order_id;
