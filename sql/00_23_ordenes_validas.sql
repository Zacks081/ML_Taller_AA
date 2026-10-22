-- Módulo 0 · Órdenes válidas: base común para el resto del taller
-- Requiere haber ejecutado antes 00_22_ordenes_marcadas.sql
CREATE OR REPLACE TEMP TABLE ordenes_validas AS
SELECT *
FROM ordenes_marcadas
WHERE en_periodo_util
  AND tiene_items
  AND fechas_coherentes;
