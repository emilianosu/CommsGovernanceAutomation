-- profile_communication_types.sql
-- Valores reales de `communication_type`, para cerrar el mapeo Channel -> communication_type
-- (SPEC-001 §4.1) y el riesgo R10 del DISCOVERY.
--
-- Ejecutada el 2026-09-02 vía execute_sql_read_only. Resultado: exactamente 3 valores.
--
--   communication_type | rows_n  | templates_n | first_date | last_date
--   -------------------+---------+-------------+------------+-----------
--   Email              | 424,675 |       2,336 | 2019-07-02 | 2026-09-02
--   Push               | 307,478 |       1,515 | 2019-07-10 | 2026-09-02
--   Announcement       |  25,602 |         489 | 2023-07-31 | 2026-09-02
--
-- Los tres son Capitalized, sin variantes de case ni espacios. El `upper(...)` que aplica el
-- notebook *Non-recurrent Monitoring* en sus filtros no era necesario para esta columna: R10
-- (comparación inconsistente entre filtros y unpivot) NO puede producir discrepancias aquí.
-- El criterio de comparación queda fijado: igualdad exacta contra el valor Capitalized.

SELECT
    communication_type,
    count(*)                       AS rows_n,
    count(DISTINCT template_name)  AS templates_n,
    min(formatted_date)            AS first_date,
    max(formatted_date)            AS last_date
FROM etl.mx__dataset.communications_monitoring
GROUP BY communication_type
ORDER BY rows_n DESC;
