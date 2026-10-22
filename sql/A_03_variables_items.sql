-- Módulo A. Variables de los ítems de cada orden.
-- Se agrega order_items por orden antes de unir, para no multiplicar filas.
-- Todo esto se conoce cuando la orden se aprueba: qué se compró, a quién, a qué precio
-- y desde dónde se despacha.
CREATE OR REPLACE TEMP TABLE variables_items AS
WITH items AS (
    SELECT
        i.order_id,
        i.seller_id,
        i.price,
        i.freight_value,
        i.shipping_limit_date,
        p.categoria_en,
        p.peso_g,
        p.volumen_cm3,
        s.seller_state,
        g_v.lat AS lat_vendedor,
        g_v.lng AS lng_vendedor,
        g_c.lat AS lat_cliente,
        g_c.lng AS lng_cliente,
        a.customer_state,
        a.fecha_compra
    FROM order_items AS i
    JOIN poblacion_a AS a USING (order_id)
    JOIN productos_limpios AS p USING (product_id)
    JOIN sellers AS s USING (seller_id)
    LEFT JOIN geo_prefijo AS g_v ON g_v.prefijo = lpad(s.seller_zip_code_prefix, 5, '0')
    LEFT JOIN geo_prefijo AS g_c ON g_c.prefijo = a.customer_prefijo
),
items_con_distancia AS (
    SELECT
        *,
        -- Distancia en línea recta (haversine) entre vendedor y cliente, en km
        2 * 6371 * asin(sqrt(
            pow(sin(radians(lat_cliente - lat_vendedor) / 2), 2)
            + cos(radians(lat_vendedor)) * cos(radians(lat_cliente))
              * pow(sin(radians(lng_cliente - lng_vendedor) / 2), 2)
        )) AS distancia_km
    FROM items
)
SELECT
    order_id,
    count(*)                                         AS n_items,
    count(DISTINCT seller_id)                        AS n_vendedores,
    sum(price)                                       AS precio_total,
    sum(freight_value)                               AS flete_total,
    sum(freight_value) / nullif(sum(price), 0)       AS flete_relativo,
    sum(peso_g)                                      AS peso_total_g,
    sum(volumen_cm3)                                 AS volumen_total_cm3,
    max(distancia_km)                                AS distancia_km,
    bool_and(seller_state = customer_state)::INT     AS misma_uf,
    -- Del ítem más caro se toman la categoría y el estado del vendedor principal
    arg_max(categoria_en, price)                     AS categoria,
    arg_max(seller_state, price)                     AS estado_vendedor,
    -- Plazo que tiene el vendedor para entregar al transportador (se fija al comprar)
    date_diff('hour', min(fecha_compra), min(shipping_limit_date)) / 24.0 AS dias_limite_despacho
FROM items_con_distancia
GROUP BY order_id;
