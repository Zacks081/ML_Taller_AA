-- Módulo 0 · Calidad de la tabla geolocation
-- Caja aproximada de Brasil: latitud entre -34 y 5.5, longitud entre -74 y -34.
SELECT
    count(*)                                                        AS filas,
    count(DISTINCT geolocation_zip_code_prefix)                     AS prefijos,
    round(count(*) / count(DISTINCT geolocation_zip_code_prefix), 1) AS filas_por_prefijo,
    count(*) - count(DISTINCT (geolocation_zip_code_prefix,
                               geolocation_lat, geolocation_lng))   AS filas_duplicadas_exactas,
    sum((geolocation_lat NOT BETWEEN -34 AND 5.5
         OR geolocation_lng NOT BETWEEN -74 AND -34)::INT)          AS puntos_fuera_de_brasil
FROM geolocation;
