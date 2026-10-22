-- Módulo 0 · Calidad de products: categorías y dimensiones
SELECT 'productos sin categoría' AS chequeo,
       count(*)                  AS registros,
       NULL                      AS detalle
FROM products
WHERE product_category_name IS NULL
UNION ALL
SELECT 'categorías sin traducción',
       count(DISTINCT p.product_category_name),
       string_agg(DISTINCT p.product_category_name, ', ')
FROM products AS p
WHERE p.product_category_name IS NOT NULL
  AND p.product_category_name NOT IN (SELECT product_category_name FROM category_translation)
UNION ALL
SELECT 'productos con categoría sin traducción',
       count(*),
       NULL
FROM products AS p
WHERE p.product_category_name IS NOT NULL
  AND p.product_category_name NOT IN (SELECT product_category_name FROM category_translation)
UNION ALL
SELECT 'productos sin peso o dimensiones',
       count(*),
       NULL
FROM products
WHERE product_weight_g IS NULL OR product_length_cm IS NULL
   OR product_height_cm IS NULL OR product_width_cm IS NULL
UNION ALL
SELECT 'productos con peso = 0 g',
       count(*),
       NULL
FROM products
WHERE product_weight_g = 0;
