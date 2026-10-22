-- Módulo 0 · Prefijos postales sin geolocalización
-- En los CSV de customers y sellers los prefijos perdieron los ceros a la izquierda
-- (p. ej. '1151' en vez de '01151'), mientras geolocation sí los conserva.
-- Se compara el cruce crudo contra el cruce después de rellenar con lpad(…, 5, '0').
WITH geo AS (
    SELECT DISTINCT geolocation_zip_code_prefix AS prefijo FROM geolocation
)
SELECT
    'customers'                                                                AS tabla,
    count(*)                                                                   AS registros,
    sum((length(customer_zip_code_prefix) < 5)::INT)                           AS prefijos_con_menos_de_5_digitos,
    sum((customer_zip_code_prefix NOT IN (SELECT prefijo FROM geo))::INT)      AS sin_geo_cruce_crudo,
    sum((lpad(customer_zip_code_prefix, 5, '0')
         NOT IN (SELECT prefijo FROM geo))::INT)                               AS sin_geo_cruce_corregido
FROM customers
UNION ALL
SELECT
    'sellers',
    count(*),
    sum((length(seller_zip_code_prefix) < 5)::INT),
    sum((seller_zip_code_prefix NOT IN (SELECT prefijo FROM geo))::INT),
    sum((lpad(seller_zip_code_prefix, 5, '0') NOT IN (SELECT prefijo FROM geo))::INT)
FROM sellers;
