-- Módulo 0 · Embudo de limpieza: cuántas órdenes quedan después de cada decisión
-- Requiere haber ejecutado antes 00_22_ordenes_marcadas.sql
SELECT '1. Órdenes en la base' AS paso, count(*) AS ordenes
FROM ordenes_marcadas
UNION ALL
SELECT '2. Compradas dentro del período útil', count(*)
FROM ordenes_marcadas WHERE en_periodo_util
UNION ALL
SELECT '3. … y con al menos un ítem', count(*)
FROM ordenes_marcadas WHERE en_periodo_util AND tiene_items
UNION ALL
SELECT '4. … y con fechas coherentes  → ordenes_validas', count(*)
FROM ordenes_marcadas WHERE en_periodo_util AND tiene_items AND fechas_coherentes
UNION ALL
SELECT '5. … y entregadas con fecha de entrega (población del Módulo A)', count(*)
FROM ordenes_marcadas WHERE en_periodo_util AND tiene_items AND fechas_coherentes AND entregada
UNION ALL
SELECT '6. … y con fecha de aprobación', count(*)
FROM ordenes_marcadas
WHERE en_periodo_util AND tiene_items AND fechas_coherentes AND entregada AND tiene_aprobacion
ORDER BY paso;
