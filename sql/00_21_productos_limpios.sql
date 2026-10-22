-- Módulo 0 · Tabla limpia de productos
-- Decisiones: categoría nula → 'sin_categoria'; las 2 categorías sin traducción se traducen
-- a mano; peso 0 g se trata como faltante; se calcula el volumen del paquete en cm³.
CREATE OR REPLACE TEMP TABLE productos_limpios AS
SELECT
    p.product_id,
    coalesce(p.product_category_name, 'sin_categoria')                 AS categoria_pt,
    coalesce(
        t.product_category_name_english,
        CASE p.product_category_name
            WHEN 'pc_gamer' THEN 'pc_gamer'
            WHEN 'portateis_cozinha_e_preparadores_de_alimentos'
                 THEN 'portable_kitchen_and_food_preparers'
        END,
        'unknown'
    )                                                                  AS categoria_en,
    p.product_photos_qty                                               AS n_fotos,
    nullif(p.product_weight_g, 0)                                      AS peso_g,
    p.product_length_cm                                                AS largo_cm,
    p.product_height_cm                                                AS alto_cm,
    p.product_width_cm                                                 AS ancho_cm,
    p.product_length_cm * p.product_height_cm * p.product_width_cm     AS volumen_cm3
FROM products AS p
LEFT JOIN category_translation AS t USING (product_category_name);
