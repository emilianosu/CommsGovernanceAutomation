# PLAN — MXCE-1025

| | |
|---|---|
| **Estado** | Draft — milestones por bloque a definir en la working session del 2026-09-03 16:00 |
| **Última actualización** | 2026-08-31 |

---

## 1. Principio de secuenciación

Entrega por etapas (decisión **D2**): primero un flujo end-to-end funcional, y los guardrails se endurecen
después **contra datos reales del sistema**. El razonamiento: diseñar reglas sin datos produce reglas
equivocadas, y bloquear la entrega hasta tener reglas perfectas no produce nada.

Cada slice tiene su propio mini-spec, escrito cuando se construye — no antes.

## 2. Secuencia

| # | Slice | Estado | Depende de | Bloqueadores |
|---|---|---|---|---|
| **1** | **Trazabilidad** — contrato de `template_name` + reconciliación | 📝 [SPEC-001](./SPEC-001-template-name-traceability.md) en revisión | — | Ninguno duro |
| 2 | **Intake** — Slack Workflow → Jira MEXCOMS | ⏸ No iniciado | — | ⚠️ Ticket a Atlassian Support (portal 1880) |
| 3 | **Validation engine** — guardrails, ~10 canales | ⏸ No iniciado | Slice 2 | ⚠️ `R-DUR-01` y `R-VOL-01` sin valor (ADR-0003) |
| 4 | **Calendario** — publicación al aprobar | ⏸ No iniciado | Slice 3 | ADR-0005 (tooling) |
| 5 | **Dashboard** — performance self-service | ⏸ No iniciado | Slice 1 | ADR-0005 (tooling) |
| — | **Overlap de poblaciones** | 🔬 Spike | — | ADR-0001 |

```
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
|---|---|---|
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
2. Discovery con el as-is, el contrato de datos verificado y los 8 riesgos →
   [DISCOVERY](./DISCOVERY-MXCE-1025.md).
3. El slice 1 especificado → [SPEC-001](./SPEC-001-template-name-traceability.md).
4. Cinco decisiones abiertas con opciones y trade-offs, listas para cerrarse → [`adr/`](../adr/).

**Decisiones a cerrar en la sesión:**

| Decisión | Quién decide | ADR |
|---|---|---|
| Enfoque de overlap (3 opciones) | Eduardo | [0001](../adr/0001-overlap-population-approach.md) |
| ¿Gobernar 10 canales sin poder medir 7? | Majo + Eduardo | [0002](../adr/0002-channel-scope-vs-instrumentation.md) |
| Valores de duración máxima y límite por cliente | **Majo** | [0003](../adr/0003-guardrail-thresholds-ownership.md) |
| ¿Reconciliación post-send o llave nueva? | Eduardo | [0004](../adr/0004-ticket-monitoring-join-key.md) |
| Tooling de calendario y dashboard | Majo + Eduardo | [0005](../adr/0005-calendar-dashboard-tooling.md) |

## 5. Contexto de disponibilidad

| Fecha | Nota |
|---|---|
| Martes 2026-09-01 | Eduardo fuera (mudanza) |
| Miércoles 2026-09-02 | Eduardo de vuelta — ventana para el gate técnico del SPEC-001 |
| **Jueves 2026-09-03 16:00** | **Working session con Majo y Eduardo** |

## 6. Pendientes de housekeeping

- [ ] Escribir la descripción de MXCE-1025 (hoy `null`) y sus criterios de aceptación.
- [ ] Crear subtasks por slice en el board MXCE.
- [ ] Revisar la prioridad del card: hoy `Low`, con el epic padre en `Backlog`.
