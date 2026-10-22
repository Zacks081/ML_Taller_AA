-- Módulo A. Variables de pago de cada orden.
-- El pago se define al comprar y se confirma con la aprobación.
CREATE OR REPLACE TEMP TABLE variables_pagos AS
SELECT
    p.order_id,
    arg_max(p.payment_type, p.payment_value)     AS medio_pago,
    max(p.payment_installments)                  AS cuotas,
    count(*)                                     AS n_pagos
FROM order_payments AS p
JOIN poblacion_a AS a USING (order_id)
GROUP BY p.order_id;
