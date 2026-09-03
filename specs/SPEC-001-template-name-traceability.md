# SPEC-001 — Trazabilidad: `template_name` como join key

| | |
| --- | --- |
| **Jira** | [MXCE-1025](https://nubank.atlassian.net/browse/MXCE-1025) |
| **Estado** | Draft — para revisar en la working session del 2026-09-03 |
| **Última actualización** | 2026-09-02 |
| **Gate técnico** | Eduardo Jurado — ⬜ pendiente |
| **Gate de negocio** | Maria Jose Salinas — ⬜ pendiente (toca el contrato de naming, que afecta a los squads) |

---

## 1. Contexto

Ataca **P4** del charter: no existe llave confiable entre un ticket de MEXCOMS y sus filas de performance en
`etl.mx__dataset.communications_monitoring`. Sin eso no se puede atribuir rendimiento al equipo solicitante,
ni construir el dashboard (O6), ni cerrar el ciclo de governance.

Es el **primer slice** (decisión **D8**) porque:

- No depende de terceros — a diferencia del intake, que necesita un ticket a Atlassian Support (riesgo R3).
- No necesita que Majo defina umbrales — a diferencia de los guardrails (riesgo R2).
- Es territorio de Analytics Engineering puro.
- Desbloquea el dashboard, que es lo que los squads piden.

Ver [`DISCOVERY-MXCE-1025.md`](./DISCOVERY-MXCE-1025.md) §5.3 para el hallazgo que lo hace barato: **los tres
componentes de la PK ya son capturables en el form v2**.

## 2. Objetivo medible

Cerrar **O1**: que una comunicación aprobada pueda resolverse a sus filas de monitoreo.

| Métrica | Baseline | Meta | Cómo se mide |
| --- | --- | --- | --- |
| % de comms aprobadas cuyo `template_name` hace match en `communications_monitoring` | **`TBD`** — bloqueado por `S1-R2` | **`TBD`** — se fija al conocer el baseline | Query de reconciliación (§7) sobre ventana acordada |

> ⚠️ **La meta no se fija antes del baseline.** Poner un número ahora sería inventarlo. La meta se acuerda
> con Eduardo en el gate técnico, con el dato en mano.

**Estado al 2026-09-02.** El acceso a `databricks-sql` quedó resuelto y el **lado de monitoreo del baseline
ya está medido** ([`sql/`](../sql/), tres queries ejecutadas). Lo que sigue faltando es el **lado del
ticket**: el porcentaje de match no se puede calcular sin la data de MEXCOMS, y cómo se expone hacia
Databricks es `S1-R2` — pregunta abierta para Eduardo.

Lo que sí queda fijado hoy es el **denominador**: en la ventana 2026-06-01 → 2026-09-02 hay **1,075
templates no recurrentes** distintos (más 88 journey-moment que el governance no cubre). Ese es el universo
contra el que se medirá el match, y es un orden de magnitud manejable para el muestreo manual del §7 paso 2
si `S1-R2` no se resuelve a tiempo.

## 3. Alcance / No-alcance

### Dentro

- Contrato de naming de `template_name`: formato, normalización, unicidad, propiedad del valor.
- Mapeo `Channel` (form v2) → `communication_type` (tabla).
- Query de reconciliación post-send ticket ↔ monitoreo.
- Medición del baseline actual del gap.

### Fuera

- Cambiar el formulario de MEXCOMS *(Slice 2 — depende de Atlassian Support, R3)*.
- Construir el dashboard *(Slice 5 — consume este join)*.
- Modificar `CommunicationsMonitoring.scala` o los datasets upstream *(no-objetivo del charter)*.
- Los 7 canales sin instrumentación y los 2 ítems de 1ª capa *(ADR-0002 — no tienen filas que reconciliar)*.

## 4. Contrato de datos

**Destino:** `etl.mx__dataset.communications_monitoring` — 21 columnas, verificado vía `DESCRIBE TABLE` el
2026-08-31. Schema completo en [`DISCOVERY`](./DISCOVERY-MXCE-1025.md) §5.1.

**Grain:** una fila por `(template_name, communication_type, formatted_date)` — la PK y la llave del join.

| Componente PK | Tipo | Origen en el intake (form v2) |
| --- | --- | --- |
| `template_name` | `string` | Campo 6 / 10 / 14 — *Channel N Template Name* (texto abierto) |
| `communication_type` | `string` | Campo 3 / 7 / 11 — *Channel N* (selección única) |
| `formatted_date` | `date` | Campos 4-5 / 8-9 / 12-13 — *Start / End Date* por canal |

**Invariante:** la tabla es append-only y solo la escriben envíos reales. **Todo join es post-send.**

**Lado del ticket:** proyecto `MEXCOMS` (Jira Service Management, portal 1880, queue 9010).
⬜ *Pendiente:* confirmar cómo se expone la data de Jira hacia Databricks — es una pregunta abierta desde la
reunión del 2026-08-28 y condiciona si la reconciliación es una query, un dataset o un proceso manual.

### 4.1 Mapeo de canales

✅ **Verificado el 2026-09-02** contra datos reales
([`profile_communication_types.sql`](../sql/profile_communication_types.sql)). La columna tiene
**exactamente 3 valores**, en title case, sin variantes de case ni espacios. La hipótesis del notebook
*Non-recurrent Monitoring* era correcta:

| Channel (form v2) | `communication_type` | Filas | Templates | Instrumentado |
| --- | --- | --- | --- | --- |
| Email | `Email` | 424,675 | 2,336 | ✅ |
| Push notification | `Push` | 307,478 | 1,515 | ✅ |
| In-App Announcement | `Announcement` | 25,602 | 489 | ✅ |
| Now Dashboard · Highlight (CC) · Highlight (Cuenta) · Discover More · Pop up · WhatsApp · SMS | — | 0 | 0 | ❌ sin filas |

> **`R10` del DISCOVERY queda cerrado.** El riesgo era que el notebook filtrara con `upper(...)` pero
> hiciera el unpivot con igualdad exacta contra `'Email'`. Como no existe ninguna variante de case en la
> columna, esa inconsistencia **no puede producir discrepancias**. El criterio de comparación queda fijado:
> igualdad exacta contra el valor title case.
>
> `Announcement` arranca en **2023-07-31**, cuatro años después que Email y Push: cualquier baseline sobre
> ventana larga tiene que acotarse por canal o subestimará la cobertura de announcements.

## 5. Reglas

| ID | Regla | Fuente | Estado |
| --- | --- | --- | --- |
| `R-TPL-01` | `template_name` debe coincidir **exactamente** con el nombre registrado en la herramienta `communication_handler` | Descripción de la columna en `CommunicationsMonitoring.scala` | Activa |
| `R-TPL-02` | La comparación de `template_name` se hace normalizada: `trim` + colapso de espacios internos + case-folding | Propuesta de este spec | ⬜ Pendiente de gate — ✅ verificada sin colisiones |
| `R-TPL-03` | Cada canal de un ticket lleva **su propio** `template_name`; un ticket con 3 canales produce 3 llaves | Form v2, campos 6/10/14 | Activa |
| `R-TPL-04` | Un `template_name` no puede reutilizarse en dos comms distintas con ventanas de fecha traslapadas | Propuesta de este spec | ⬜ Pendiente de gate |
| `R-TPL-05` | El contrato de naming **no debe romper** el filtro `template_name LIKE '%jm%'` de `JourneyMomentCommunicationsMonitoring` | `JourneyMomentCommunicationsMonitoring.scala` | Activa — restricción dura |

> `R-TPL-05` es una restricción real descubierta en el código: existe un dataset downstream que depende del
> naming actual. Cualquier convención propuesta debe verificarse contra él **antes** del gate.
>
> ✅ **Verificado el 2026-09-02** ([`verify_journey_moment_filter.sql`](../sql/verify_journey_moment_filter.sql)):
> 120 templates hacen match con `%jm%`, y son **exactamente los mismos 120** con o sin case-folding. Aplicar
> `R-TPL-02` no cambia el conjunto que ve el dataset downstream. La restricción se cumple.

### 5.1 Hallazgos del perfilado que el contrato debe absorber

Medidos el 2026-09-02 sobre las 757,755 filas
([`profile_template_names.sql`](../sql/profile_template_names.sql)):

| Hallazgo | Dato | Qué implica para el contrato |
| --- | --- | --- |
| **Cero colisiones bajo normalización** | 4,238 distintos = 4,238 normalizados | `R-TPL-02` es segura, pero no rescata nada. No hay variantes por case que unificar |
| **Las dos convenciones no conviven** | Las rutas con slashes mueren el **2023-06-19**; desde entonces todo es kebab-case | Los 676 templates con slashes son un bloque histórico **cerrado**. El contrato puede declararlos irrecuperables sin costo operativo |
| **Centinela `NO-TEMPLATE`** | 1,217 filas, **2.1M de envíos**, último el 2022-09-13 | Histórico, pero el contrato debe **prohibirlo explícitamente**: es lo que un campo de texto libre invita a escribir cuando el requester no sabe qué poner |
| **`template_name` no es único por canal** | 102 templates aparecen bajo 2 `communication_type` | ⚠️ Ver abajo — cambia la llave |

> ⚠️ **La llave de join es el par `(template_name, communication_type)`, no `template_name` solo.**
> El grain de §4 ya lo decía, pero el nombre del slice y el enunciado de O1 sugieren lo contrario. Un join
> por `template_name` suelto contra un ticket multicanal **duplicaría filas y atribuiría el performance del
> canal equivocado**. Son 102 de 4,238 (2.4%) — poco volumen, pero es corrupción silenciosa de datos, no
> ruido estadístico.

**Lectura de conjunto:** el naming histórico está **mucho mejor** de lo que anticipaba `S1-R3`. La hipótesis
era que la inconsistencia obligaría a bajar la meta de O1 alcanzable; los datos dicen que la inconsistencia
es histórica y ya cerrada. Eso **debilita** el argumento a favor de una llave nueva y **refuerza** vivir con
reconciliación post-send — insumo directo de [ADR-0004](../adr/0004-ticket-monitoring-join-key.md).

**`R-TPL-02` no impone nada nuevo.** El notebook *Non-recurrent Monitoring* ya aplica `upper(template_name)`
en sus filtros — necesitó case-folding para que las búsquedas funcionaran. La regla formaliza una
normalización que en la práctica ya se hace a mano; eso es lo que conviene llevar al gate.

## 6. Criterios de aceptación

- [ ] Baseline medido y documentado. **Lado de monitoreo hecho** el 2026-09-02: 4,238 `template_name`
      distintos, 100% sobrevive la normalización de `R-TPL-02` sin colisionar, denominador no recurrente de
      1,075. **Falta el % de match contra tickets** — bloqueado por `S1-R2`.
- [ ] Contrato de naming escrito, con ejemplos válidos e inválidos.
- [x] Verificado que el contrato no rompe `JourneyMomentCommunicationsMonitoring` (`R-TPL-05`) —
      [`verify_journey_moment_filter.sql`](../sql/verify_journey_moment_filter.sql), 2026-09-02.
- [ ] Query de reconciliación en `sql/`, ejecutable y comentada, que dada una ventana devuelve por ticket:
      filas de monitoreo encontradas, o el motivo de la falla de match.
- [x] Mapeo `Channel` → `communication_type` verificado contra valores reales de la tabla (§4.1) —
      [`profile_communication_types.sql`](../sql/profile_communication_types.sql), 2026-09-02.
- [ ] Meta de O1 acordada con Eduardo, con el baseline en mano.
- [ ] [ADR-0004](../adr/0004-ticket-monitoring-join-key.md) resuelto: se vive con reconciliación post-send, o
      se propone llave nueva.

## 7. Plan de verificación

1. ✅ **Perfilado del estado actual** — hecho el **2026-09-02**, read-only sobre las 757,755 filas de
   `etl.mx__dataset.communications_monitoring`. Resultados en [`sql/`](../sql/) y en §5.1.
2. ⬜ **Muestreo de tickets** — tomar tickets de MEXCOMS de una ventana conocida e intentar el match a mano.
   Da el % de match y, sobre todo, **los modos de falla**. **Bloqueado por `S1-R2`.**
3. ⬜ **Query de reconciliación** — implementarla en `sql/`, correrla sobre la ventana y contrastar contra el
   match manual del paso 2. Debe joinear por el **par** `(template_name, communication_type)` — ver `S1-R7`.
4. ✅ **Verificar `R-TPL-05`** — hecho: los 120 templates que hacen match con `%jm%` son los mismos con o sin
   case-folding. Falta re-verificarlo cuando el contrato de naming completo esté escrito.
5. ⬜ **Gate técnico con Eduardo** — revisar baseline, contrato y query; fijar la meta de O1.

Convenciones: `execute_sql_read_only`, naming de 3 niveles, `LIMIT 100` al explorar, CTEs sobre subqueries.

## 8. Riesgos y dependencias

| ID | Riesgo | Impacto | Mitigación |
| --- | --- | --- | --- |
| S1-R2 | Cómo se expone Jira hacia Databricks está sin definir | **Alto** — condiciona si la reconciliación es automatizable | Pregunta para Eduardo en el gate; mientras tanto, muestreo manual sobre los 1,075 templates de §2 |
| S1-R4 | `template_name` es texto abierto en el form v2 | El contrato es convención, no restricción del sistema | Proponer validación en el mismo ticket de Atlassian Support de R3/R4/R5. El centinela `NO-TEMPLATE` de §5.1 es la evidencia de que el riesgo ya se materializó |
| S1-R5 | Cambiar la convención puede romper `JourneyMomentCommunicationsMonitoring` | Alto — dataset downstream de otro squad | ✅ `R-TPL-02` verificada contra el filtro: no cambia el conjunto de 120 templates. Falta re-verificar cuando el contrato completo esté escrito |
| **S1-R7** | La llave real es el par `(template_name, communication_type)`: 102 templates existen bajo dos canales | **Alto** — un join por `template_name` solo duplica filas y atribuye performance al canal equivocado | Fijar el par como llave en el contrato y en la query de reconciliación. Ver §5.1 |

### Naming observado en producción

Los dos ejemplos que documenta el notebook parecían **dos convenciones conviviendo en la misma columna**:

```text
coll-roxinha2-d-mail-d30                          ← kebab-case con prefijos de dominio
acquisition/duplicate-email/emails/default/v1     ← ruta con slashes y versión
```

✅ **Corregido con datos el 2026-09-02: no conviven, se sucedieron.** La convención de rutas con slashes
tiene su última fila el **2023-06-19**; desde entonces las 628,478 filas escritas son kebab-case. Los dos
ejemplos del notebook son reales, pero uno de ellos es histórico.

Eso cambia la respuesta a "qué hacer con el histórico que no cumple el contrato": no hay que normalizarlo ni
mapearlo, se puede **declarar irrecuperable** — nadie escribe en esa convención desde hace más de tres años.
Insumo directo de [ADR-0004](../adr/0004-ticket-monitoring-join-key.md), y en la dirección de vivir con
reconciliación post-send en vez de pedir una llave nueva.

## 9. Decisiones abiertas

| Pregunta | ADR | Dueño | Supuesto mientras tanto |
| --- | --- | --- | --- |
| ¿Reconciliación post-send con `template_name`, o llave nueva? | [ADR-0004](../adr/0004-ticket-monitoring-join-key.md) | Eduardo | Se vive con reconciliación post-send |
| ¿Qué valor de meta para O1? | — | Eduardo | Se fija con el baseline en mano |
| ¿Cómo llega la data de Jira a Databricks? | ⬜ por abrir si el gate no lo resuelve | Eduardo | Muestreo manual para el baseline |
