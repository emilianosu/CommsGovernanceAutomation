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

## Pendientes (§7 de SPEC-001)

- [ ] `profile_template_names.sql` — `template_name` distintos, distribución temporal, patrones de naming
      inconsistente (variantes por case, espacios, sufijos de fecha), y colisiones bajo la normalización de
      `R-TPL-02`.
- [ ] `profile_communication_types.sql` — valores reales de `communication_type`, para cerrar el mapeo
      `Channel` → `communication_type` (§4.1 de SPEC-001).
- [ ] `reconcile_ticket_to_monitoring.sql` — el join post-send: dado una ventana, por ticket devuelve las
      filas de monitoreo encontradas o el motivo de la falla de match.
- [ ] `verify_journey_moment_filter.sql` — verificar que el contrato de naming propuesto no cambia qué
      templates hace match `LIKE '%jm%'` (restricción `R-TPL-05`).

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
