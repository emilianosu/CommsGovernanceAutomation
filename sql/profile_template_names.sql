-- profile_template_names.sql
-- Perfilado de `template_name`: cardinalidad, colisiones bajo normalización, patrones de naming
-- y distribución temporal. Paso 1 del plan de verificación de SPEC-001 §7.
--
-- Ejecutado el 2026-09-02 vía execute_sql_read_only sobre 757,755 filas
-- (ventana completa 2019-07-02 → 2026-09-02). Resultados inline en cada bloque.

-- ---------------------------------------------------------------------------------------------
-- 1. Cardinalidad y colisiones bajo la normalización de R-TPL-02 (upper + trim)
--
--    rows_total | templates_distinct | templates_normalized | template_null
--    -----------+--------------------+----------------------+---------------
--       757,755 |              4,238 |                4,238 |             0
--
--    templates_distinct == templates_normalized => CERO colisiones. No existen variantes por
--    case ni por espacios en los extremos: la normalización es segura, pero tampoco rescata
--    nada. El riesgo S1-R3 no se materializa por esta vía.
-- ---------------------------------------------------------------------------------------------
SELECT
    count(*)                                                    AS rows_total,
    count(DISTINCT template_name)                               AS templates_distinct,
    count(DISTINCT upper(trim(template_name)))                  AS templates_normalized,
    sum(CASE WHEN template_name IS NULL THEN 1 ELSE 0 END)      AS template_null,
    min(formatted_date)                                         AS first_date,
    max(formatted_date)                                         AS last_date
FROM etl.mx__dataset.communications_monitoring;

-- ---------------------------------------------------------------------------------------------
-- 2. Patrones de naming sobre los 4,238 template_name distintos
--
--    patron           | templates_n
--    -----------------+-------------
--    kebab-case       |       3,556
--    ruta con slashes |         676
--    sin separador    |           6
--
--    Sin snake_case y sin espacios internos. Solo dos convenciones reales.
-- ---------------------------------------------------------------------------------------------
WITH t AS (SELECT DISTINCT template_name FROM etl.mx__dataset.communications_monitoring)
SELECT
    CASE
        WHEN template_name LIKE '%/%'  THEN 'ruta con slashes'
        WHEN template_name LIKE '%\_%' THEN 'snake_case'
        WHEN template_name LIKE '% %'  THEN 'contiene espacios'
        WHEN template_name LIKE '%-%'  THEN 'kebab-case'
        ELSE 'sin separador'
    END       AS patron,
    count(*)  AS templates_n
FROM t
GROUP BY 1
ORDER BY templates_n DESC;

-- ---------------------------------------------------------------------------------------------
-- 3. HALLAZGO PRINCIPAL — las dos convenciones NO conviven: se sucedieron en el tiempo
--
--    patron            | primera    | ultima     | rows_n
--    ------------------+------------+------------+---------
--    ruta con slashes  | 2019-07-02 | 2023-06-19 | 129,277
--    kebab-case / otro | 2020-06-10 | 2026-09-02 | 628,478
--
--    La convención de rutas con slashes MURIÓ el 2023-06-19. Desde entonces, todo lo escrito es
--    kebab-case. SPEC-001 §8 asumía dos convenciones conviviendo en la misma columna — cierto
--    sobre el histórico completo, falso sobre los datos vigentes.
--
--    Consecuencia para el contrato de naming: los 676 templates con slashes son un bloque
--    histórico cerrado, no un problema activo. El contrato puede declararlos irrecuperables sin
--    costo operativo, en vez de tener que normalizarlos o mapearlos.
-- ---------------------------------------------------------------------------------------------
SELECT
    CASE WHEN template_name LIKE '%/%' THEN 'ruta con slashes' ELSE 'kebab-case / otro' END AS patron,
    min(formatted_date) AS primera,
    max(formatted_date) AS ultima,
    count(*)            AS rows_n
FROM etl.mx__dataset.communications_monitoring
GROUP BY 1;

-- ---------------------------------------------------------------------------------------------
-- 4. Valores centinela — `NO-TEMPLATE` y equivalentes
--
--    communication_type | rows_n | enviados  | primera    | ultima
--    -------------------+--------+-----------+------------+------------
--    Push               |    803 | 1,863,410 | 2020-07-01 | 2022-09-13
--    Email              |    414 |   315,023 | 2020-06-10 | 2021-08-25
--
--    Existe un centinela `NO-TEMPLATE` con 2.1M de envíos detrás: comms que salieron sin
--    template identificable. Es un modo de falla de trazabilidad REAL, pero histórico — el
--    último es de 2022-09-13. Ninguna fila reciente lo usa.
--
--    Aun así el contrato de naming debe prohibirlo explícitamente: es precisamente el valor que
--    un formulario de texto libre invita a escribir cuando el requester no sabe qué poner.
-- ---------------------------------------------------------------------------------------------
SELECT
    communication_type,
    count(*)                   AS rows_n,
    sum(total_templates_sent)  AS enviados,
    min(formatted_date)        AS primera,
    max(formatted_date)        AS ultima
FROM etl.mx__dataset.communications_monitoring
WHERE upper(trim(template_name)) IN ('NO-TEMPLATE', 'NO_TEMPLATE', 'NA', 'N/A', '')
   OR template_name IS NULL
GROUP BY communication_type
ORDER BY rows_n DESC;

-- ---------------------------------------------------------------------------------------------
-- 5. `template_name` NO es único por canal
--
--    canales_n | templates_n
--    ----------+-------------
--            1 |       4,136
--            2 |         102
--
--    102 templates aparecen bajo dos communication_type distintos. Por eso 2,336 + 1,515 + 489
--    = 4,340 pero los distintos son 4,238.
--
--    Consecuencia dura para SPEC-001: la llave de join es el PAR
--    (template_name, communication_type), no `template_name` solo. Un join por template_name
--    contra un ticket multicanal duplicaría filas y atribuiría performance del canal equivocado.
-- ---------------------------------------------------------------------------------------------
WITH per_template AS (
    SELECT template_name, count(DISTINCT communication_type) AS canales_n
    FROM etl.mx__dataset.communications_monitoring
    GROUP BY template_name
)
SELECT canales_n, count(*) AS templates_n
FROM per_template
GROUP BY canales_n
ORDER BY canales_n;
