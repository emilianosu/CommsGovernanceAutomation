# SPEC-001 — Trazabilidad: `template_name` como join key

| | |
|---|---|
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
|---|---|---|---|
| % de comms aprobadas cuyo `template_name` hace match en `communications_monitoring` | **`TBD`** — pendiente de medir | **`TBD`** — se fija al conocer el baseline | Query de reconciliación (§7) sobre una ventana histórica acordada |

> ⚠️ **La meta no se fija antes del baseline.** Poner un número ahora sería inventarlo. Medir el baseline es
> la primera tarea de este slice; la meta se acuerda con Eduardo en el gate técnico, con el dato en mano.

## 3. Alcance / No-alcance

**Dentro**
- Contrato de naming de `template_name`: formato, normalización, unicidad, propiedad del valor.
- Mapeo `Channel` (form v2) → `communication_type` (tabla).
- Query de reconciliación post-send ticket ↔ monitoreo.
- Medición del baseline actual del gap.

**Fuera**
- Cambiar el formulario de MEXCOMS *(Slice 2 — depende de Atlassian Support, R3)*.
- Construir el dashboard *(Slice 5 — consume este join)*.
- Modificar `CommunicationsMonitoring.scala` o los datasets upstream *(no-objetivo del charter)*.
- Los 7 canales sin instrumentación y los 2 ítems de 1ª capa *(ADR-0002 — no tienen filas que reconciliar)*.

## 4. Contrato de datos

**Destino:** `etl.mx__dataset.communications_monitoring` — 21 columnas, verificado vía `DESCRIBE TABLE` el
2026-08-31. Schema completo en [`DISCOVERY`](./DISCOVERY-MXCE-1025.md) §5.1.

**Grain:** una fila por `(template_name, communication_type, formatted_date)` — la PK y la llave del join.

| Componente PK | Tipo | Origen en el intake (form v2) |
|---|---|---|
| `template_name` | `string` | Campo 6 / 10 / 14 — *Channel N Template Name* (texto abierto) |
| `communication_type` | `string` | Campo 3 / 7 / 11 — *Channel N* (selección única) |
| `formatted_date` | `date` | Campos 4-5 / 8-9 / 12-13 — *Start / End Date* por canal |

**Invariante:** la tabla es append-only y solo la escriben envíos reales. **Todo join es post-send.**

**Lado del ticket:** proyecto `MEXCOMS` (Jira Service Management, portal 1880, queue 9010).
⬜ *Pendiente:* confirmar cómo se expone la data de Jira hacia Databricks — es una pregunta abierta desde la
reunión del 2026-08-28 y condiciona si la reconciliación es una query, un dataset o un proceso manual.

### 4.1 Mapeo de canales

Los valores de `communication_type` deben verificarse contra datos reales antes de fijar el mapeo.
El notebook *Non-recurrent Monitoring* aporta una **hipótesis con origen** —su unpivot compara contra
`'Email'`, `'Push'` y `'Announcement'` en title case exacto— pero eso es un supuesto de su autor, no un hecho
verificado. Se registra como tal:

| Channel (form v2) | `communication_type` esperado | Instrumentado |
|---|---|:--:|
| Email | `Email` — ⬜ asumido por el notebook, sin verificar | ✅ |
| Push notification | `Push` — ⬜ asumido por el notebook, sin verificar | ✅ |
| In-App Announcement | `Announcement` — ⬜ asumido por el notebook, sin verificar | ✅ |
| Now Dashboard · Highlight (CC) · Highlight (Cuenta) · Discover More · Pop up · WhatsApp · SMS | — | ❌ sin filas |

## 5. Reglas

| ID | Regla | Fuente | Estado |
|---|---|---|---|
| `R-TPL-01` | `template_name` debe coincidir **exactamente** con el nombre registrado en la herramienta `communication_handler` | Descripción de la columna en `CommunicationsMonitoring.scala` | Activa |
| `R-TPL-02` | La comparación de `template_name` se hace normalizada: `trim` + colapso de espacios internos + case-folding | Propuesta de este spec | ⬜ Pendiente de gate |
| `R-TPL-03` | Cada canal de un ticket lleva **su propio** `template_name`; un ticket con 3 canales produce 3 llaves | Form v2, campos 6/10/14 | Activa |
| `R-TPL-04` | Un `template_name` no puede reutilizarse en dos comms distintas con ventanas de fecha traslapadas | Propuesta de este spec | ⬜ Pendiente de gate |
| `R-TPL-05` | El contrato de naming **no debe romper** el filtro `template_name LIKE '%jm%'` de `JourneyMomentCommunicationsMonitoring` | `JourneyMomentCommunicationsMonitoring.scala` | Activa — restricción dura |

> `R-TPL-05` es una restricción real descubierta en el código: existe un dataset downstream que depende del
> naming actual. Cualquier convención propuesta debe verificarse contra él **antes** del gate.

**`R-TPL-02` no impone nada nuevo.** El notebook *Non-recurrent Monitoring* ya aplica `upper(template_name)`
en sus filtros — necesitó case-folding para que las búsquedas funcionaran. La regla formaliza una
normalización que en la práctica ya se hace a mano; eso es lo que conviene llevar al gate.

## 6. Criterios de aceptación

- [ ] Baseline medido y documentado: número de `template_name` distintos, % de valores que sobreviven la
      normalización de `R-TPL-02` sin colisionar, y % de match actual contra tickets.
- [ ] Contrato de naming escrito, con ejemplos válidos e inválidos.
- [ ] Verificado que el contrato no rompe `JourneyMomentCommunicationsMonitoring` (`R-TPL-05`).
- [ ] Query de reconciliación en `sql/`, ejecutable y comentada, que dada una ventana devuelve por ticket:
      filas de monitoreo encontradas, o el motivo de la falla de match.
- [ ] Mapeo `Channel` → `communication_type` verificado contra valores reales de la tabla (§4.1).
- [ ] Meta de O1 acordada con Eduardo, con el baseline en mano.
- [ ] [ADR-0004](../adr/0004-ticket-monitoring-join-key.md) resuelto: se vive con reconciliación post-send, o
      se propone llave nueva.

## 7. Plan de verificación

1. **Perfilado del estado actual** — read-only sobre `etl.mx__dataset.communications_monitoring`:
   - `template_name` distintos y su distribución en el tiempo.
   - Valores de `communication_type` reales (cierra §4.1).
   - Detección de patrones de naming inconsistente: variantes por case, espacios, sufijos de fecha.
   - Cuántos valores colisionarían al aplicar la normalización de `R-TPL-02`.
2. **Muestreo de tickets** — tomar tickets de MEXCOMS de una ventana conocida e intentar el match a mano.
   Da el baseline real y, sobre todo, **los modos de falla**.
3. **Query de reconciliación** — implementarla en `sql/`, correrla sobre la ventana y contrastar contra el
   match manual del paso 2.
4. **Verificar `R-TPL-05`** — confirmar que ningún template real que hoy hace match con `%jm%` cambia de
   clasificación bajo el contrato propuesto.
5. **Gate técnico con Eduardo** — revisar baseline, contrato y query; fijar la meta de O1.

Convenciones: `execute_sql_read_only`, naming de 3 niveles, `LIMIT 100` al explorar, CTEs sobre subqueries.

## 8. Riesgos y dependencias

| ID | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| S1-R2 | Cómo se expone Jira hacia Databricks está sin definir | **Alto** — condiciona si la reconciliación es automatizable | Pregunta para Eduardo en el gate; mientras tanto, muestreo manual |
| S1-R3 | El naming histórico puede ser tan inconsistente que la normalización no rescate lo suficiente | Medio — bajaría la meta de O1 alcanzable | Es justo lo que mide el paso 1; si es el caso, refuerza ADR-0004 |
| S1-R4 | `template_name` es texto abierto en el form v2 | El contrato es convención, no restricción del sistema | Proponer validación en el mismo ticket de Atlassian Support de R3/R4/R5 |
| S1-R5 | Cambiar la convención puede romper `JourneyMomentCommunicationsMonitoring` | Alto — dataset downstream de otro squad | `R-TPL-05` como restricción dura; verificar antes del gate |
| S1-R6 | Los valores reales de `communication_type` siguen sin verificar (§4.1); el MCP `databricks-sql` requiere autenticación | Medio — bloquea cerrar el mapeo de canales y el riesgo R10 del DISCOVERY | Es el paso 1 del §7; resolver el acceso antes del gate |

> *`S1-R1` (falta de permiso al notebook) se retiró el 2026-09-01: el acceso quedó resuelto. Su ID no se
> recicla.*

### Naming observado en producción

Los dos ejemplos que documenta el notebook son **dos convenciones distintas conviviendo en la misma
columna** — el mejor anticipo disponible de lo que va a encontrar el baseline (`S1-R3`):

```text
coll-roxinha2-d-mail-d30                          ← kebab-case con prefijos de dominio
acquisition/duplicate-email/emails/default/v1     ← ruta con slashes y versión
```

Difieren en separador, en profundidad y en si llevan versión. Un contrato de naming tiene que decidir qué
hacer con el histórico que no lo cumple: normalizar, mapear, o declararlo irrecuperable — y esa respuesta es
justamente el insumo de [ADR-0004](../adr/0004-ticket-monitoring-join-key.md).

## 9. Decisiones abiertas

| Pregunta | ADR | Dueño | Supuesto mientras tanto |
|---|---|---|---|
| ¿Reconciliación post-send con `template_name`, o llave nueva? | [ADR-0004](../adr/0004-ticket-monitoring-join-key.md) | Eduardo | Se vive con reconciliación post-send |
| ¿Qué valor de meta para O1? | — | Eduardo | Se fija con el baseline en mano |
| ¿Cómo llega la data de Jira a Databricks? | ⬜ por abrir si el gate no lo resuelve | Eduardo | Muestreo manual para el baseline |
