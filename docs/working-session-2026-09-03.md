# Working session — 2026-09-03 16:00

| | |
| --- | --- |
| **Asistentes** | Maria Jose Salinas (negocio) · Eduardo Jurado (técnica) · Emiliano Mendoza (AE) |
| **Objetivo** | Cerrar las 5 decisiones abiertas y fijar los milestones del [PLAN](../specs/PLAN-MXCE-1025.md) §4 |
| **Preparado** | 2026-09-02 |

Este documento **no sustituye a los ADRs** — los resume en formato decidible. Cada sección liga al ADR, que
es donde vive el análisis completo. Si algo se decide aquí, se registra en el ADR correspondiente y se pasa
su estado de `Proposed` a `Accepted`.

---

## Resumen

| # | Decisión | Decide | Bloquea | Hay recomendación |
| --- | --- | --- | --- | :--: |
| [1](#1--adr-0004-llave-de-join-ticket--monitoreo) | Llave de join ticket ↔ monitoreo | Eduardo | **Slice 1, en curso** | ✅ opción C |
| [2](#2--adr-0003-valores-de-los-umbrales-de-guardrails) | Valores de `R-DUR-01`, `R-VOL-01`, `R-OVL-01` | **Majo** | **Slice 3** | ➖ es política, no técnica |
| [3](#3--adr-0002-alcance-de-canales-vs-instrumentación-d9) | Alcance de canales (ratificar `D9`) | Majo + Eduardo | Slice 3, y el alcance de O1 | ✅ opción B como C |
| [4](#4--adr-0001-enfoque-de-cálculo-de-overlap) | Enfoque de cálculo de overlap | Eduardo | Spike (fuera de ruta crítica) | ➖ definir el spike, no la opción |
| [5](#5--adr-0005-tooling-de-calendario-y-dashboard) | Tooling de calendario y dashboard | Majo + Eduardo | Slices 4 y 5 | ➖ se puede posponer |

**Orden sugerido:** 1 → 2 → 3 → 4 → 5. Las dos primeras son las únicas que bloquean trabajo ya en curso o
inmediato. Las 4 y 5 pueden cerrarse en otra sesión sin costo: el charter deja el tooling como **no-objetivo
explícito**, y `D6` saca el overlap de la ruta crítica.

---

## 1 — [ADR-0004](../adr/0004-ticket-monitoring-join-key.md): llave de join ticket ↔ monitoreo

**La pregunta:** ¿se vive con reconciliación post-send sobre `template_name`, o se introduce una llave
dedicada que viaje del ticket hasta el envío?

**Restricción dura, verificada en código:** `communications_monitoring` es append-only y solo la escriben
envíos reales. **Cualquier join es post-send**; no hay forma de escribir la liga en tiempo de guardrail.

| Opción | Trade-off en una frase |
| --- | --- |
| **A** — reconciliación sobre `template_name` | Barata, retroactiva y sin dependencias externas, pero el contrato es convención y no restricción del sistema |
| **B** — llave dedicada | Match determinista, pero toca `communication_handler` y el pipeline de Itaipu — atraviesa un no-objetivo del charter, depende de terceros y no aplica al histórico |
| **C** — híbrida | A ahora, B como spec de largo plazo si el baseline demuestra que hace falta |

**Recomendación: C.** El form v2 **ya captura los tres componentes de la PK** (campos 3/7/11, 4-5/8-9/12-13 y
6/10/14): la llave no falta en el diseño, falta validarla.

> ✅ **Evidencia nueva — perfilado del 2026-09-02** ([`sql/`](../sql/), 757,755 filas). El argumento a favor
> de **A** se fortaleció con datos:
>
> - **Cero colisiones** al normalizar: 4,238 `template_name` distintos siguen siendo 4,238 tras `upper+trim`.
> - **Las dos convenciones de naming no conviven, se sucedieron.** Las rutas con slashes tienen su última
>   fila el **2023-06-19**; desde entonces todo es kebab-case. El histórico "irrecuperable" es un bloque
>   cerrado de hace tres años, no un problema activo.
>
> Es decir: el escenario que justificaba **B** —naming tan inconsistente que la normalización no rescata—
> **no se materializó**. La decisión puede tomarse mañana con datos, no con intuición.
>
> ⚠️ **Pero apareció otra cosa:** 102 templates existen bajo **dos** `communication_type` distintos. La llave
> es el par `(template_name, communication_type)`, no `template_name` solo. No cambia la elección A/B/C —
> cambia cómo se escribe la query en cualquiera de las tres. Registrado como `S1-R7`.

**Si se decide B:** el Slice 1 cambia de alcance por completo, pasa a depender de equipos externos, y la
decisión `D8` del charter (trazabilidad como primer slice) tendría que revisarse.

---

## 2 — [ADR-0003](../adr/0003-guardrail-thresholds-ownership.md): valores de los umbrales de guardrails

**La pregunta, para Majo:** tres reglas del validation engine no tienen valor numérico en ningún documento.

| ID | Regla | Qué falta exactamente |
| --- | --- | --- |
| `R-DUR-01` | Duración máxima de una comm por canal | El número de días, por cada canal |
| `R-VOL-01` | Límite de comms por cliente, por canal y periodo | El número, y el periodo |
| `R-OVL-01` | Umbral de overlap que dispara rechazo o revisión manual | El porcentaje de audiencia compartida |

No son decisiones técnicas. Un ingeniero no puede inventar cuántas comms al día es aceptable que reciba un
cliente; eso lo define quien responde por la experiencia.

**Pista útil para `R-VOL-01`:** la política declarada en *Mexico Comms Governance Process Sept 2025* ya dice
*"limitar el número de comms que un cliente puede recibir de Nu **por día**"*. El periodo probablemente sea
diario; **el número nunca se escribió**.

**El Slice 3 no está bloqueado del todo.** `R-APR-01/02/03`, `R-CAD-01` y `R-REV-01` ya son deterministas y
se pueden codificar tal cual. Las tres reglas sin valor se construyen **parametrizables**: la estructura
ahora, el valor por configuración cuando exista.

**Sugerencia de método:** un valor provisional hoy no es un problema si se declara como tal. Una vez que el
Slice 1 dé trazabilidad se puede medir cuántas comms recibe hoy un cliente típico y refinar el umbral contra
lo observado. Fijar algo provisional ahora **no bloquea nada** y evita la falla opuesta: inventar un umbral
que después se aplica como si fuera política aprobada.

---

## 3 — [ADR-0002](../adr/0002-channel-scope-vs-instrumentation.md): alcance de canales vs. instrumentación (`D9`)

**La pregunta:** ¿el validation engine gobierna los 12 ítems del form v2, o solo los 3 que se pueden medir?

```text
12 ítems bajo governance
  ├─ 3 instrumentados ............ Announcement · Push · Email
  ├─ 7 canales sin instrumentar .. Now Dashboard · Highlight (CC) · Highlight (Cuenta) ·
  │                                Discover More · Pop up · WhatsApp · SMS
  └─ 2 ítems de 1ª capa de app ... Experiment proposal · Experiment roll out
```

**Recomendación — y es lo que `D9` ya dice: opción B ejecutada como C.** Gobernar los 12 y documentar la
asimetría en cada artefacto en lugar de esconderla. El argumento de fondo: las reglas de fechas, duración,
approvers y cadencia **se validan contra lo que declara el ticket** — no necesitan instrumentación. Lo que sí
queda fuera de alcance para los 7 canales es verificar el cumplimiento *después* del envío.

⚠️ **Consecuencia que conviene aceptar en voz alta:** si un equipo excede la duración aprobada en un
Highlight, el sistema **no lo detecta post-hoc**. Se marcan `governed, unmeasured`, y un canal sin datos debe
verse siempre como *"sin instrumentación"*, **nunca** como *"sin actividad"*.

### ⬜ Sub-pregunta nueva, para Majo

*Experiment proposal* y *Experiment roll out* son **modificaciones de la 1ª capa de la app, no envíos de
comunicación**. Pasan por el mismo flujo de aprobación, pero contarlos como "canales" es lo que hacía que
este alcance apareciera unas veces como 10 y otras como 12 en los propios documentos del proyecto.

**¿Entran al validation engine como canales, o son una categoría aparte con sus propias reglas?** La
respuesta cambia qué reglas les aplican (`R-DUR-01` sobre un roll out de experimento no significa lo mismo
que sobre un email) y cierra la única ambigüedad de alcance que queda en el charter.

---

## 4 — [ADR-0001](../adr/0001-overlap-population-approach.md): enfoque de cálculo de overlap

**La pregunta:** ¿cómo se detecta que dos comms van a los mismos clientes?

**El problema duro:** la elegibilidad **cambia a diario**. La población calculada al agendar no es la que
recibirá la comm el día del envío. Por consenso de las tres reuniones es el componente más complejo del
proyecto, y por eso `D6` lo saca de la ruta crítica.

| Opción | Trade-off en una frase |
| --- | --- |
| **A** — poblaciones vivas | Simple y de baja latencia, pero el overlap puede haber derivado para la fecha de envío |
| **B** — re-segmentar al momento del check | La más precisa, pero exige que **cada equipo exponga su lógica de segmentación de forma ejecutable** — hoy no existe |
| **C** — listas congeladas point-in-time | Barata y **auditable** (queda registro de contra qué se validó), pero puede no ver traslape que aparece después |

**Lo que conviene decidir mañana no es la opción, es el spike.** El enfoque acordado el 2026-08-28 ya da
un camino concreto: comparar campañas **por fechas primero** —barato, descarta la mayoría de los pares—,
calcular audiencias solo de las que se traslapan en el tiempo, y hacer el join para el % de clientes
compartidos. Filtrar por fecha antes de calcular poblaciones es lo que hace tratable el problema.

⬜ **Pendiente que sí bloquea el spike:** localizar el *Campaign Coalition Checker* (app de Streamlit, ya
inactiva, nunca llegó a un repo). Es efectivamente una implementación de la opción C. ¿Alguien sabe dónde
quedó el código, o al menos capturas? Si no aparece, se reescribe.

> Nota: `R-OVL-01` (el umbral) es de Majo y vive en el punto 2, no aquí. Esta decisión es el **método**;
> aquella es el **número**.

---

## 5 — [ADR-0005](../adr/0005-calendar-dashboard-tooling.md): tooling de calendario y dashboard

**La pregunta:** ¿con qué se construyen el calendario (Slice 4) y el dashboard (Slice 5)?

**Se puede posponer sin costo** — el charter lo deja como no-objetivo explícito y los slices 4 y 5 no están
cerca. Lo que sí conviene resolver hoy es lo que tiene lead time.

**Hallazgo del 2026-09-01 que cambia el planteamiento del dashboard:** el notebook *Non-recurrent Monitoring*
de Eduardo (`2219645164459186`) **ya cubre buena parte de O6** — filtros por rango de fechas, template y canal
(exactamente los tres ejes que pedía la reunión del 2026-08-25), pivot a matriz template × métrica × día,
export a CSV y ordenamiento. Lo que le falta **no es filtrado**: le falta acceso para los squads y la liga al
ticket. Y la liga al ticket es el Slice 1, no el 5.

**Lo único con lead time real: el acceso de los squads.** Las tres opciones (Databricks dashboard, QuickSight,
extender el notebook) lo requieren, y es el tipo de permiso cuyo tiempo de tramitación no controlamos.
Conviene iniciarlo ahora aunque el tooling no esté decidido.

**Para el calendario:** reusar el Apps Script conserva el punto de falla que **P2** justamente busca eliminar.
Vale como puente, difícilmente como destino.

---

## Preguntas para Eduardo — gate técnico del [SPEC-001](../specs/SPEC-001-template-name-traceability.md)

1. **¿Cómo se expone la data de Jira hacia Databricks?** (`S1-R2`) Es una pregunta abierta desde el
   2026-08-28 y condiciona si la reconciliación es una query, un dataset o un proceso manual. **Alto impacto:**
   determina si el Slice 1 es automatizable.
2. **Meta de O1.** No se fija antes del baseline. El **lado de monitoreo ya está medido**; falta el lado del
   ticket, que depende de la pregunta 1. El denominador sí quedó fijado: **1,075 templates no recurrentes**
   distintos en la ventana 2026-06-01 → 2026-09-02 — un universo chico, muestreable a mano si la pregunta 1
   no se resuelve pronto. Lo que se pide mañana es acordar la ventana de medición.
3. **`S1-R7` — la llave es un par, no una columna.** 102 templates aparecen bajo dos `communication_type`
   distintos. ¿Es intencional (una misma campaña reusando nombre en Email y Push) o es contaminación de
   naming? La respuesta decide si el contrato lo prohíbe o lo acomoda.
4. **Confirmar un comportamiento de tu notebook** — registrado como riesgo, no como reproche: es razonable
   para un visor de métricas y problemático solo si el dashboard de governance lo hereda.
   - **`R9`** — `HAVING max(coalesce(metric_value, 0.0)) > 0` excluye todo template cuyo mejor rate en la
     ventana sea 0. Una comm **enviada sin engagement desaparece de la vista sin aviso**, y para governance
     esa es justo la fila que hay que ver.

> ✅ **Dos puntos que estaban en esta lista salieron el 2026-09-02 y ya no ocupan tiempo de la sesión:**
> el **acceso a `databricks-sql`** quedó resuelto y el perfilado corrió, y con él **`R10` quedó cerrado** —
> la columna tiene 3 valores sin ninguna variante de case, así que la comparación inconsistente del notebook
> no puede producir discrepancias.

## Pendientes que necesitan a Majo

- Los tres valores del punto 2 (`R-DUR-01`, `R-VOL-01`, `R-OVL-01`) — o un provisional declarado como tal.
- La sub-pregunta de `D9` del punto 3: los ítems de *Experiment*.
- **Ratificar `D9`** formalmente: el charter lo registra desde el 2026-08-31 como pendiente de ratificación.

## Salida esperada de la sesión

- [ ] Las 5 decisiones cerradas o con fecha de cierre, y sus ADRs pasados a `Accepted`.
- [ ] Milestones del [PLAN](../specs/PLAN-MXCE-1025.md) §4, hoy `⬜ A definir en la working session`.
- [ ] Gate técnico del SPEC-001 resuelto (Eduardo) y gate de negocio del contrato de naming (Majo).
- [ ] Tres pendientes de housekeeping del PLAN §6: descripción de MXCE-1025, subtasks por slice, y revisar
      la prioridad del card (hoy `Low`, con el epic padre en `Backlog`).
