-- Módulo 0 · Órdenes por semana de compra dentro del período útil
-- Solo se incluyen semanas completas (lunes a domingo) para no distorsionar los extremos.
-- Parámetros: ? = inicio (incluido), ? = fin (excluido)
WITH periodo AS (
    SELECT ?::TIMESTAMP AS inicio, ?::TIMESTAMP AS fin
)
SELECT
    date_trunc('week', o.order_purchase_timestamp)::DATE  AS semana,
    count(*)                                              AS ordenes
FROM orders AS o
CROSS JOIN periodo AS p
WHERE date_trunc('week', o.order_purchase_timestamp) >= p.inicio
  AND date_trunc('week', o.order_purchase_timestamp) + INTERVAL 7 DAY <= p.fin
GROUP BY semana
ORDER BY semana;
