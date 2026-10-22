-- Módulo 0 · Tabla limpia: una coordenada por prefijo postal
-- Decisiones: (1) se descartan puntos fuera de la caja de Brasil, (2) se toma la MEDIANA
-- de latitud y longitud de cada prefijo (robusta a puntos atípicos), (3) el prefijo se
-- normaliza a 5 dígitos para que cruce con customers y sellers.
CREATE OR REPLACE TEMP TABLE geo_prefijo AS
SELECT
    lpad(geolocation_zip_code_prefix, 5, '0')  AS prefijo,
    median(geolocation_lat)                    AS lat,
    median(geolocation_lng)                    AS lng,
    count(*)                                   AS n_puntos
FROM geolocation
WHERE geolocation_lat BETWEEN -34 AND 5.5
  AND geolocation_lng BETWEEN -74 AND -34
GROUP BY prefijo;
