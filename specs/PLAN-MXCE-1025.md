# PLAN — MXCE-1025

| | |
| --- | --- |
| **Estado** | Draft — milestones por bloque a definir en la working session del 2026-09-03 16:00 |
| **Última actualización** | 2026-09-02 |

---

## 1. Principio de secuenciación

Entrega por etapas (decisión **D2**): primero un flujo end-to-end funcional, y los guardrails se endurecen
después **contra datos reales del sistema**. El razonamiento: diseñar reglas sin datos produce reglas
equivocadas, y bloquear la entrega hasta tener reglas perfectas no produce nada.

Cada slice tiene su propio mini-spec, escrito cuando se construye — no antes.

## 2. Secuencia

| # | Slice | Estado | Depende de | Bloqueadores |
| --- | --- | --- | --- | --- |
| **1** | **Trazabilidad** — contrato de `template_name` + reconciliación | 📝 [SPEC-001](./SPEC-001-template-name-traceability.md) en revisión | — | Ninguno duro |
| 2 | **Intake** — Slack Workflow → Jira MEXCOMS | ⏸ No iniciado | — | ⚠️ Ticket a Atlassian Support (portal 1880) |
| 3 | **Validation engine** — guardrails, 12 ítems | ⏸ No iniciado | Slice 2 | ⚠️ `R-DUR-01` y `R-VOL-01` sin valor (ADR-0003) |
| 4 | **Calendario** — publicación al aprobar | ⏸ No iniciado | Slice 3 | ADR-0005 (tooling) |
| 5 | **Dashboard** — performance self-service | ⏸ No iniciado | Slice 1 | ADR-0005 (tooling) |
| — | **Overlap de poblaciones** | 🔬 Spike | — | ADR-0001 |

```text
Slice 1 (trazabilidad) ──────────────────────────────▶ Slice 5 (dashboard)
                                                          ▲
Slice 2 (intake) ──▶ Slice 3 (guardrails) ──▶ Slice 4 (calendario)
                          ▲
Spike overlap ────────────┘  (se integra cuando ADR-0001 se resuelva)
```

**Por qué 1 va primero** (D8): no depende de terceros, no necesita definiciones de negocio, es territorio de
AE puro, y desbloquea el dashboard — que es el entregable visible para los squads. Los slices 2 y 3, que
parecían el arranque natural, tienen dependencias externas que no controlamos.

**Por qué el overlap va aparte** (D6): es el componente más complejo (la elegibilidad cambia a diario) y
mantenerlo en la ruta crítica bloquearía todo lo demás.

## 3. Paralelización

Trabajo que puede avanzar sin esperar al slice anterior:

| Cuándo | Qué | Por qué ahora |
| --- | --- | --- |
| **Ya** | Abrir el ticket a Atlassian Support con R3 + R4 + R5 juntos | Lead time externo — abrirlo temprano es lo único que lo acorta |
| **Ya** | Escalar a Majo los valores de `R-DUR-01` / `R-VOL-01` | Desbloquea el Slice 3 antes de llegar ahí |
| Durante Slice 1 | Spike de overlap: revisar *Campaign Coalition Checker* | Alimenta ADR-0001 sin bloquear |

> El ticket a Atlassian Support debería llevar **los tres cambios juntos**: hacer requeridos los campos
> 24-26 (reviewers de Legal/Content/Ops, hoy opcionales — R4), volver `Squad` una selección controlada (R5),
> y validar el formato de `template_name` (S1-R4). Ir tres veces por lo mismo desperdicia el lead time.

## 4. Milestones

⬜ **A definir en la working session del jueves 2026-09-03 16:00** con Majo y Eduardo.

Insumos que este repo lleva a esa sesión:

1. Charter con objetivos, no-objetivos y las 9 decisiones cerradas → [SPEC-000](./SPEC-000-charter.md).
2. Discovery con el as-is, el contrato de datos verificado y los 10 riesgos →
   [DISCOVERY](./DISCOVERY-MXCE-1025.md).
3. El slice 1 especificado → [SPEC-001](./SPEC-001-template-name-traceability.md).
4. Cinco decisiones abiertas con opciones y trade-offs, listas para cerrarse → [`adr/`](../adr/).

**Timeline propuesto (borrador, para validar hoy):** semanas de calendario, con margen para el lead time
externo (tickets, aprobaciones, valores de Majo) y para que un solo desarrollador (Emi) lo lleve sin
dedicación exclusiva. Se ajusta en vivo con lo que se decida en la sesión.

| Slice | Duración estimada | Ventana objetivo | Depende de / bloqueado por |
| --- | --- | --- | --- |
| 1 — Trazabilidad | 2-3 semanas — cerrar `ADR-0004`, redactar el contrato final de naming y pasar el gate técnico | Septiembre | Ninguno duro; ya casi listo (`SPEC-001` en revisión) |
| 2 — Intake | 4-6 semanas, incluyendo el lead time del ticket a Atlassian Support (no lo controlamos) | Septiembre-Octubre | Ticket a Atlassian Support (portal 1880) |
| 3 — Validation engine | 5-7 semanas, incluyendo esperar los valores de Majo y ciclos de ajuste de reglas contra datos reales | Octubre-Noviembre | Slice 2 · valores de Majo (`ADR-0003`) |
| 4 — Calendario | 3-5 semanas | Noviembre-Diciembre | Slice 3 · `ADR-0005` |
| 5 — Dashboard | 4-6 semanas — puede arrancar en paralelo apenas cierre el Slice 1 | Septiembre-Noviembre, en paralelo | Slice 1 · `ADR-0005` |
| Overlap (spike) | 6-10 semanas — es el componente más complejo (D6); corre en paralelo sin bloquear | Septiembre-Enero | `ADR-0001` |

Camino crítico aproximado (1 → 2 → 3 → 4, secuencial): **14-21 semanas** de trabajo efectivo. El resto del
margen es buffer para integración end-to-end, ajustes tras ver datos reales, y tiempos de espera externos que
hoy no podemos acotar.

> Los slices 2, 3 y 4 tienen su reloj real fuera de nuestro control (tickets externos, valores de negocio).
> El camino que sí depende solo de nosotros es 1 → 5 (dashboard) — arranca primero, aunque no es el que
> cierra el proyecto.

**Decisiones a cerrar en la sesión:**

| Decisión | Quién decide | ADR |
| --- | --- | --- |
| Enfoque de overlap (3 opciones) | Eduardo | [0001](../adr/0001-overlap-population-approach.md) |
| ¿Gobernar 12 ítems sin poder medir 7 de los 9 canales? | Majo + Eduardo | [0002](../adr/0002-channel-scope-vs-instrumentation.md) |
| Valores de duración máxima y límite por cliente | **Majo** | [0003](../adr/0003-guardrail-thresholds-ownership.md) |
| ¿Reconciliación post-send o llave nueva? | Eduardo | [0004](../adr/0004-ticket-monitoring-join-key.md) |
| Tooling de calendario y dashboard | Majo + Eduardo | [0005](../adr/0005-calendar-dashboard-tooling.md) |

## 5. Contexto de disponibilidad

| Fecha | Nota |
| --- | --- |
| Martes 2026-09-01 | Eduardo fuera (mudanza) |
| Miércoles 2026-09-02 | Eduardo de vuelta — ventana para el gate técnico del SPEC-001 |
| **Jueves 2026-09-03 16:00** | **Working session con Majo y Eduardo** |

## 6. Pendientes de housekeeping

- [ ] Abrir cada slice como **story propia bajo el epic [MXCE-1260]** cuando arranque — no como subtask de
      MXCE-1025, que se cierra al terminar el discovery.

[MXCE-1260]: https://nubank.atlassian.net/browse/MXCE-1260
