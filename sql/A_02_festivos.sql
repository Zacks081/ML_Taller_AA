-- Módulo A. Tabla de festivos nacionales de Brasil.
-- La lista de fechas llega como parámetro desde Python (librería holidays).
CREATE OR REPLACE TEMP TABLE festivos AS
SELECT DISTINCT unnest(?::DATE[]) AS fecha;
