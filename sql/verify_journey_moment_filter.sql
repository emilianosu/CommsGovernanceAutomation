-- verify_journey_moment_filter.sql
-- Verifica la restricción dura R-TPL-05: el contrato de naming no debe cambiar qué templates
-- hace match el filtro `template_name LIKE '%jm%'` de JourneyMomentCommunicationsMonitoring,
-- dataset downstream de otro squad.
--
-- Ejecutado el 2026-09-02 vía execute_sql_read_only.

-- ---------------------------------------------------------------------------------------------
-- 1. Sensibilidad al case del filtro downstream
--
--    match_jm_lower | match_jm_case_insensitive | con_espacios_extremos | con_sufijo_fecha | total
--    ---------------+---------------------------+-----------------------+------------------+-------
--               120 |                       120 |                     0 |               10 | 4,238
--
--    Los dos conteos coinciden: no existe ningún template con `JM` en mayúsculas que el filtro
--    downstream esté perdiendo hoy. Aplicar la normalización de R-TPL-02 (upper + trim) NO
--    cambia el conjunto que hace match => R-TPL-05 se cumple. Verificado antes del gate, como
--    exige SPEC-001 §5.
-- ---------------------------------------------------------------------------------------------
WITH t AS (SELECT DISTINCT template_name FROM etl.mx__dataset.communications_monitoring)
SELECT
    sum(CASE WHEN template_name LIKE '%jm%' THEN 1 ELSE 0 END)             AS match_jm_lower,
    sum(CASE WHEN upper(template_name) LIKE '%JM%' THEN 1 ELSE 0 END)      AS match_jm_case_insensitive,
    sum(CASE WHEN template_name <> trim(template_name) THEN 1 ELSE 0 END)  AS con_espacios_extremos,
    sum(CASE WHEN template_name RLIKE '[0-9]{4}[-_]?[0-9]{2}' THEN 1 ELSE 0 END) AS con_sufijo_fecha,
    count(*)                                                               AS templates_total
FROM t;

-- ---------------------------------------------------------------------------------------------
-- 2. Universo no recurrente — el denominador real del baseline de O1
--
--    Ventana 2026-06-01 → 2026-09-02:
--
--    clase                       | templates_n | rows_n
--    ----------------------------+-------------+--------
--    no recurrente               |       1,075 | 53,189
--    journey moment (recurrente) |          88 |  1,598
--
--    El governance de Majo cubre SOLO lo no recurrente (no-objetivo del charter §3). El
--    denominador del baseline de O1 en un trimestre es ~1,075 templates, no 4,238.
--
--    ⚠️ `%jm%` es una heurística de subcadena, no una clasificación: hace match con cualquier
--    'jm' en cualquier posición. Se usa aquí por consistencia con el filtro downstream, pero el
--    contrato de naming debería darle un prefijo o segmento propio en vez de una subcadena
--    suelta. Punto para el gate técnico con Eduardo.
-- ---------------------------------------------------------------------------------------------
SELECT
    CASE WHEN template_name LIKE '%jm%'
         THEN 'journey moment (recurrente)'
         ELSE 'no recurrente' END  AS clase,
    count(DISTINCT template_name)  AS templates_n,
    count(*)                       AS rows_n
FROM etl.mx__dataset.communications_monitoring
WHERE formatted_date >= '2026-06-01'
GROUP BY 1;
