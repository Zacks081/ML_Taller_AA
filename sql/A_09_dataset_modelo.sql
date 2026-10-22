-- Módulo A. Tabla final para el modelo: una fila por orden con todas las variables.
-- Todas las tablas que se unen tienen una fila por orden, así que no se multiplican filas.
SELECT
    a.order_id,
    a.fecha_compra,
    a.particion,
    a.tarde,
    a.customer_state                       AS estado_cliente,
    i.estado_vendedor,
    i.categoria,
    p.medio_pago,
    c.dias_prometidos,
    c.horas_hasta_aprobacion,
    c.dia_semana,
    c.hora_compra,
    c.festivos_en_plazo,
    c.ordenes_ultimos_7d,
    i.dias_limite_despacho,
    i.n_items,
    i.n_vendedores,
    i.precio_total,
    i.flete_total,
    i.flete_relativo,
    i.peso_total_g,
    i.volumen_total_cm3,
    i.distancia_km,
    i.misma_uf,
    p.cuotas,
    p.n_pagos,
    v.vendedor_n_entregas_previas,
    v.vendedor_tasa_retraso,
    v.vendedor_dias_entrega_prom,
    r.ruta_n_entregas_previas,
    r.ruta_tasa_retraso,
    r.ruta_dias_entrega_prom,
    -- Holgura: días prometidos menos lo que suele tardar esa ruta
    c.dias_prometidos - r.ruta_dias_entrega_prom   AS holgura_ruta,
    x.entregas_recientes,
    x.tasa_retraso_reciente,
    x.tasa_retraso_reciente_estado
FROM poblacion_a AS a
JOIN variables_items           AS i USING (order_id)
JOIN variables_calendario      AS c USING (order_id)
LEFT JOIN variables_pagos      AS p USING (order_id)
LEFT JOIN historico_vendedor   AS v USING (order_id)
LEFT JOIN historico_ruta       AS r USING (order_id)
LEFT JOIN contexto_operacion   AS x USING (order_id)
ORDER BY a.fecha_compra;
