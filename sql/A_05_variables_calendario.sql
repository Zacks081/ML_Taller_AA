-- Módulo A. Variables de calendario y de carga de la operación.
-- Solo usan la fecha de compra, la de aprobación y la fecha estimada, que se conocen
-- en el momento de aprobar.
CREATE OR REPLACE TEMP TABLE variables_calendario AS
WITH carga AS (
    -- Órdenes compradas en los 7 días anteriores a cada orden (presión sobre la logística)
    SELECT
        order_id,
        count(*) OVER (
            ORDER BY order_purchase_timestamp
            RANGE BETWEEN INTERVAL 7 DAY PRECEDING AND CURRENT ROW
        ) - 1 AS ordenes_ultimos_7d
    FROM ordenes_validas
)
SELECT
    a.order_id,
    date_diff('day', a.fecha_compra::DATE, a.fecha_estimada::DATE)          AS dias_prometidos,
    date_diff('minute', a.fecha_compra, a.fecha_aprobacion) / 60.0          AS horas_hasta_aprobacion,
    isodow(a.fecha_compra)                                                  AS dia_semana,
    hour(a.fecha_compra)                                                    AS hora_compra,
    (SELECT count(*) FROM festivos AS f
      WHERE f.fecha > a.fecha_compra::DATE
        AND f.fecha <= a.fecha_estimada::DATE)                             AS festivos_en_plazo,
    c.ordenes_ultimos_7d
FROM poblacion_a AS a
JOIN carga AS c USING (order_id);
