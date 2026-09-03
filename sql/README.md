# SQL

Queries de perfilado y reconciliación del [Slice 1](../specs/SPEC-001-template-name-traceability.md).

## Convenciones

- Naming de 3 niveles: `catalog.schema.table` — ej. `etl.mx__dataset.communications_monitoring`.
- `execute_sql_read_only` salvo que se pida escritura explícitamente.
- `DESCRIBE TABLE` antes de agregar una tabla nueva.
- `LIMIT 100` al explorar; se quita solo para resultados finales.
- CTEs sobre subqueries anidadas.
- Nunca `SELECT *` en tablas > 1 GB.
- Comentar la intención de negocio en la lógica de `CASE WHEN`.

## Estado (§7 de SPEC-001)

Ejecutadas el **2026-09-02** con `execute_sql_read_only`. Cada archivo lleva sus resultados inline como
comentario, para que se lean sin volver a correr nada.

- [x] [`profile_template_names.sql`](./profile_template_names.sql) — cardinalidad, colisiones bajo
      `R-TPL-02`, patrones de naming y distribución temporal.
- [x] [`profile_communication_types.sql`](./profile_communication_types.sql) — valores reales de
      `communication_type`. Cierra §4.1 de SPEC-001 y el riesgo **R10** del DISCOVERY.
- [x] [`verify_journey_moment_filter.sql`](./verify_journey_moment_filter.sql) — `R-TPL-05` verificada, y el
      denominador no recurrente del baseline de O1.
- [ ] `reconcile_ticket_to_monitoring.sql` — el join post-send. **Bloqueada por `S1-R2`:** falta saber cómo
      se expone la data de Jira hacia Databricks. Sin el lado del ticket no hay nada que reconciliar.

### Qué salió del perfilado

| Hallazgo | Dato |
| --- | --- |
| `communication_type` tiene exactamente 3 valores | `Email` · `Push` · `Announcement`, title case, sin variantes |
| La normalización de `R-TPL-02` no colisiona | 4,238 distintos = 4,238 normalizados |
| Las dos convenciones de naming no conviven | Las rutas con slashes cerraron el 2023-06-19 |
| La llave es un **par**, no una columna | 102 templates viven bajo dos `communication_type` |
| Existe un centinela `NO-TEMPLATE` | 1,217 filas, 2.1M de envíos — histórico, último en 2022-09-13 |

Detalle y consecuencias en [SPEC-001 §5.1](../specs/SPEC-001-template-name-traceability.md).

## Punto de partida

El notebook *Non-recurrent Monitoring* (`2219645164459186`, dueño: Eduardo — ver
[`docs/sources.md`](../docs/sources.md) §5) ya tiene una query sobre esta misma tabla, con el mismo grain y
un unpivot por canal que resuelve la matriz métrica↔canal. Es el mejor punto de partida para
`reconcile_ticket_to_monitoring.sql`.

**Se referencia, no se copia.** Es código de Eduardo y lo puede seguir editando; mantener aquí una copia que
diverge sería peor que no tenerla. Dos cosas que **no** hay que heredar de esa query:

| | Qué hace el notebook | Qué hacer aquí |
| --- | --- | --- |
| **R9** | `HAVING max(coalesce(metric_value, 0.0)) > 0` — oculta templates enviados con engagement cero | No filtrar por engagement. Distinguir "sin envíos" de "enviado con cero" con `total_templates_sent` |
| **R10** | Filtros con `upper(...)` pero unpivot con `communication_type = 'Email'` exacto | Un solo criterio de comparación, fijado tras verificar los valores reales |

## Nota sobre los rates

`safeRate` en `CommunicationsMonitoring.scala` devuelve `0.0` cuando el denominador es `0`. Un rate en `0.0`
puede significar "cero eventos" o "cero enviados": **siempre traer `total_templates_sent` junto al rate**.

Y no todas las columnas de rate aplican a todos los canales — ver la matriz métrica↔canal en
[`DISCOVERY`](../specs/DISCOVERY-MXCE-1025.md) §5.1 antes de calcular cualquier cobertura.
