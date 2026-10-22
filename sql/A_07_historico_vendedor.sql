-- Módulo A. Histórico de cada vendedor, calculado sin fuga de información.
-- Para cada orden solo cuentan las órdenes del mismo vendedor que ya se habían entregado
-- antes de la aprobación de esa orden. No basta con que se hubieran comprado antes,
-- porque el retraso de una orden solo se conoce cuando se entrega.
-- Se usa un ASOF JOIN: para cada orden busca el último acumulado del vendedor con fecha de
-- entrega anterior a la fecha de aprobación.
-- Parámetro: m, peso de la tasa global en el suavizado de la tasa del vendedor.
CREATE OR REPLACE TEMP TABLE historico_vendedor AS
WITH entregas AS (
    -- Una fila por vendedor y orden entregada
    SELECT DISTINCT
        i.seller_id,
        o.order_id,
        o.order_delivered_customer_date                                         AS fecha_entrega,
        (o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE)::INT AS tarde,
        date_diff('day', o.order_purchase_timestamp::DATE,
                  o.order_delivered_customer_date::DATE)                        AS dias_entrega
    FROM ordenes_validas AS o
    JOIN order_items AS i USING (order_id)
    WHERE o.entregada
),
acumulado_vendedor AS (
    SELECT
        seller_id,
        fecha_entrega,
        count(*)          OVER w AS n_previas,
        sum(tarde)        OVER w AS tardes_previas,
        sum(dias_entrega) OVER w AS dias_previos
    FROM entregas
    WINDOW w AS (PARTITION BY seller_id ORDER BY fecha_entrega)
),
acumulado_global AS (
    -- Tasa global de retraso con las entregas ocurridas hasta cada momento
    SELECT DISTINCT
        fecha_entrega,
        avg(tarde) OVER (ORDER BY fecha_entrega) AS tasa_global
    FROM (SELECT DISTINCT order_id, fecha_entrega, tarde FROM entregas)
),
pares AS (
    -- Cada orden de la población con cada uno de sus vendedores
    SELECT DISTINCT a.order_id, i.seller_id, a.fecha_aprobacion
    FROM poblacion_a AS a
    JOIN order_items AS i USING (order_id)
),
con_historico AS (
    SELECT
        p.order_id,
        coalesce(v.n_previas, 0)        AS n_previas,
        coalesce(v.tardes_previas, 0)   AS tardes_previas,
        v.dias_previos / v.n_previas    AS dias_entrega_prom,
        g.tasa_global
    FROM pares AS p
    ASOF LEFT JOIN acumulado_vendedor AS v
        ON p.seller_id = v.seller_id AND p.fecha_aprobacion > v.fecha_entrega
    ASOF LEFT JOIN acumulado_global AS g
        ON p.fecha_aprobacion > g.fecha_entrega
)
SELECT
    order_id,
    -- Si la orden tiene varios vendedores se toma el peor caso
    min(n_previas)                                                        AS vendedor_n_entregas_previas,
    max((tardes_previas + ?::DOUBLE * coalesce(tasa_global, 0))
        / (n_previas + ?::DOUBLE))                                        AS vendedor_tasa_retraso,
    max(dias_entrega_prom)                                                AS vendedor_dias_entrega_prom
FROM con_historico
GROUP BY order_id;
