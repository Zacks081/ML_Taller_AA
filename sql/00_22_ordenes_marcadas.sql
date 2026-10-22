-- Módulo 0 · Todas las órdenes con las marcas de calidad que deciden si son válidas
-- Parámetros: ? = inicio del período útil (incluido), ? = fin del período útil (excluido)
CREATE OR REPLACE TEMP TABLE ordenes_marcadas AS
WITH periodo AS (
    SELECT ?::TIMESTAMP AS inicio, ?::TIMESTAMP AS fin
)
SELECT
    o.*,
    c.customer_unique_id,
    c.customer_state,
    lpad(c.customer_zip_code_prefix, 5, '0')                                  AS customer_prefijo,
    -- Marcas de calidad
    (o.order_purchase_timestamp >= p.inicio
     AND o.order_purchase_timestamp < p.fin)                                  AS en_periodo_util,
    EXISTS (SELECT 1 FROM order_items AS i WHERE i.order_id = o.order_id)     AS tiene_items,
    -- La entrega al cliente no puede ser anterior a la entrega al transportador ni a la
    -- aprobación (la aprobación es el momento en que se usa el modelo del Módulo A).
    (coalesce(o.order_delivered_customer_date >= o.order_delivered_carrier_date, TRUE)
     AND coalesce(o.order_delivered_customer_date >= o.order_approved_at, TRUE))  AS fechas_coherentes,
    (o.order_status = 'delivered'
     AND o.order_delivered_customer_date IS NOT NULL)                         AS entregada,
    (o.order_approved_at IS NOT NULL)                                         AS tiene_aprobacion
FROM orders AS o
JOIN customers AS c USING (customer_id)
CROSS JOIN periodo AS p;
