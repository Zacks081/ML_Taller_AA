-- Módulo A. Contexto de la operación en el momento de aprobar cada orden.
-- Mide si la logística viene atrasada: proporción de entregas tardías entre las órdenes
-- que se entregaron en los días anteriores a la aprobación. Solo usa entregas que ya
-- ocurrieron, así que no hay fuga.
-- Se calcula con acumulados por fecha de entrega y dos ASOF JOIN: el acumulado hasta la
-- aprobación menos el acumulado hasta el inicio de la ventana.
-- Parámetros: días de la ventana global, días de la ventana por estado del cliente.
CREATE OR REPLACE TEMP TABLE contexto_operacion AS
WITH ventanas AS (
    SELECT ?::INTEGER AS dias_global, ?::INTEGER AS dias_estado
),
entregas AS (
    SELECT
        order_id,
        customer_state,
        order_delivered_customer_date                                              AS fecha_entrega,
        (order_delivered_customer_date::DATE > order_estimated_delivery_date::DATE)::INT AS tarde
    FROM ordenes_validas
    WHERE entregada
),
acum_global AS (
    SELECT DISTINCT
        fecha_entrega,
        count(*)   OVER w AS n,
        sum(tarde) OVER w AS tardes
    FROM entregas
    WINDOW w AS (ORDER BY fecha_entrega)
),
acum_estado AS (
    SELECT DISTINCT
        customer_state,
        fecha_entrega,
        count(*)   OVER w AS n,
        sum(tarde) OVER w AS tardes
    FROM entregas
    WINDOW w AS (PARTITION BY customer_state ORDER BY fecha_entrega)
),
base AS (
    SELECT
        a.order_id,
        a.customer_state,
        a.fecha_aprobacion,
        a.fecha_aprobacion - to_days(k.dias_global) AS inicio_global,
        a.fecha_aprobacion - to_days(k.dias_estado) AS inicio_estado
    FROM poblacion_a AS a
    CROSS JOIN ventanas AS k
),
global_hasta_hoy AS (
    SELECT b.order_id, g.n, g.tardes
    FROM base AS b
    ASOF LEFT JOIN acum_global AS g ON b.fecha_aprobacion > g.fecha_entrega
),
global_hasta_inicio AS (
    SELECT b.order_id, g.n, g.tardes
    FROM base AS b
    ASOF LEFT JOIN acum_global AS g ON b.inicio_global > g.fecha_entrega
),
estado_hasta_hoy AS (
    SELECT b.order_id, e.n, e.tardes
    FROM base AS b
    ASOF LEFT JOIN acum_estado AS e
        ON b.customer_state = e.customer_state AND b.fecha_aprobacion > e.fecha_entrega
),
estado_hasta_inicio AS (
    SELECT b.order_id, e.n, e.tardes
    FROM base AS b
    ASOF LEFT JOIN acum_estado AS e
        ON b.customer_state = e.customer_state AND b.inicio_estado > e.fecha_entrega
)
SELECT
    b.order_id,
    coalesce(gh.n, 0) - coalesce(gi.n, 0)                                     AS entregas_recientes,
    (coalesce(gh.tardes, 0) - coalesce(gi.tardes, 0))
        / nullif(coalesce(gh.n, 0) - coalesce(gi.n, 0), 0)                    AS tasa_retraso_reciente,
    (coalesce(eh.tardes, 0) - coalesce(ei.tardes, 0))
        / nullif(coalesce(eh.n, 0) - coalesce(ei.n, 0), 0)                    AS tasa_retraso_reciente_estado
FROM base AS b
JOIN global_hasta_hoy    AS gh USING (order_id)
JOIN global_hasta_inicio AS gi USING (order_id)
JOIN estado_hasta_hoy    AS eh USING (order_id)
JOIN estado_hasta_inicio AS ei USING (order_id);
